# Phase 03 — Token Refresh & Session Lifecycle

## Goal

Implement transparent token refresh so that a user's session stays alive beyond the
15-minute access token TTL without requiring re-login. If refresh fails (Redis session
expired, invalid token, or network error), the session is cleared and the user is
redirected to the sign-in page with an explanatory flash message.

---

## Scenarios covered

- Transparent token refresh before expiry (`@must`)
- Refresh fails 401 → session cleared and redirect to login (`@must`)
- No refresh when token has more than 60 s remaining (`@must`)
- Missing refresh_token in session → redirect to login (`@should`)

---

## Scope

```
app/use_cases/security/
  refresh_session.rb                (NEW)

app/controllers/
  application_controller.rb         (add ensure_fresh_session! before_action)

spec/use_cases/security/
  refresh_session_spec.rb           (NEW)
spec/requests/
  auth_sessions_spec.rb             (update — add refresh scenarios)
```

---

## Implementation detail

### 1. `Security::RefreshSession` use case

```ruby
# app/use_cases/security/refresh_session.rb
module Security
  class RefreshSession < BaseUseCase
    class RefreshFailedError < StandardError; end

    REFRESH_THRESHOLD_SECONDS = 60

    def initialize(provider_registry: Backend::ProviderRegistry.new)
      @provider_registry = provider_registry
    end

    # Returns :refreshed, :not_needed, or raises RefreshFailedError
    def call(session:)
      store    = SessionStore.new(session:)
      snapshot = store.read

      return :not_needed if snapshot.guest?
      return :not_needed unless needs_refresh?(snapshot)

      new_snapshot = provider_registry.session_provider.refresh(snapshot)
      store.persist!(snapshot: new_snapshot)
      :refreshed
    rescue Backend::Errors::AuthenticationError,
           Backend::Errors::ValidationError,
           Backend::Errors::ServiceUnavailableError => e
      raise RefreshFailedError, e.message
    end

    private

    attr_reader :provider_registry

    def needs_refresh?(snapshot)
      return true if snapshot.refresh_token.blank?

      exp = snapshot.access_token_exp
      return false if exp.nil?

      Time.now.to_i >= (exp - REFRESH_THRESHOLD_SECONDS)
    end
  end
end
```

**Design decisions:**
- `REFRESH_THRESHOLD_SECONDS = 60` means refresh fires when fewer than 60 seconds remain.
- Returns a symbol (`:refreshed` / `:not_needed`) rather than the snapshot — the caller
  re-reads from session after refresh so there is no snapshot object passed around in
  controller context.
- `RefreshFailedError` is the single error the controller needs to handle.
- Missing `refresh_token` is treated as expired — `needs_refresh?` returns `true`, then
  `provider.refresh(snapshot)` will call the API with a blank token, which returns 400/401;
  both are caught and re-raised as `RefreshFailedError`.

---

### 2. `ApplicationController` — add `ensure_fresh_session!`

Add `before_action :ensure_fresh_session!` **after** `hydrate_current_principal`:

```ruby
# app/controllers/application_controller.rb (additions)

before_action :hydrate_current_principal
before_action :ensure_fresh_session!   # ← NEW: runs after hydrate so signed_in? is available

private

def ensure_fresh_session!
  return unless signed_in?

  Security::RefreshSession.call(session:)
  # Re-hydrate principal if tokens were rotated
  hydrate_current_principal if Security::RefreshSession.new.send(:needs_refresh?,
                                                                   Security::SessionStore.new(session:).read)
rescue Security::RefreshSession::RefreshFailedError
  Security::SessionStore.new(session:).clear!
  redirect_to new_session_path, alert: t("auth.sessions.session_expired")
end
```

**Simpler implementation** — avoid re-calling `needs_refresh?` publicly; instead always
re-hydrate after refresh since it is cheap:

```ruby
def ensure_fresh_session!
  return unless signed_in?

  result = Security::RefreshSession.call(session:)
  hydrate_current_principal if result == :refreshed
rescue Security::RefreshSession::RefreshFailedError
  Security::SessionStore.new(session:).clear!
  redirect_to new_session_path, alert: t("auth.sessions.session_expired")
end
```

**Ordering guard:** The `before_action` chain is:
1. `set_locale`
2. `hydrate_current_principal` — sets `Current.principal` from session
3. `ensure_fresh_session!` — refreshes if needed, re-hydrates after rotation

This ensures `signed_in?` is accurate before the refresh check runs.

---

### `ProviderRegistry` — ensure `refresh` is routed

The `ProviderRegistry#session_provider` already returns the correct provider. No change
needed — `provider.refresh(snapshot)` will dispatch to:

- `Local::SessionProvider#refresh` (no-op rotate, no network call)
- `Remote::SessionProvider#refresh` (real API call, added in Phase 02)
- `DualCompare::SessionProvider#refresh` (delegates to both, added in Phase 02)

---

## Edge cases and guard conditions

| Condition | Behaviour |
|---|---|
| `access_token_exp` returns `nil` (malformed JWT) | Treat as expired → trigger refresh |
| `refresh_token` blank | `RefreshSession` will call provider with blank token → provider raises `AuthenticationError` / `ValidationError` → `RefreshFailedError` → session cleared |
| API 400 on refresh (blank refresh_token body) | Caught as `ValidationError` → `RefreshFailedError` |
| API 401 on refresh (Redis session gone) | Caught as `AuthenticationError` → `RefreshFailedError` |
| Network unreachable during refresh | `ServiceUnavailableError` → `RefreshFailedError` → session cleared |
| Concurrent requests both trigger refresh | Both attempt refresh; second call may get 401 on second refresh if first already rotated token. Handle: treat concurrent 401 on refresh as `RefreshFailedError` → session cleared |
| Local mode (`BFF_PROVIDER_MODE=local`) | `Local::SessionProvider#refresh` always returns a new snapshot — refresh never fails |
| `ensure_fresh_session!` on login/logout controller | Runs on `new` and `destroy` actions too; `signed_in?` guard prevents unnecessary work |

---

## Tests to add in this phase

### `spec/use_cases/security/refresh_session_spec.rb`

```ruby
RSpec.describe Security::RefreshSession do
  let(:provider)  { instance_double(Backend::Providers::Remote::SessionProvider) }
  let(:registry)  { instance_double(Backend::ProviderRegistry, session_provider: provider) }
  let(:use_case)  { described_class.new(provider_registry: registry) }

  let(:expiring_snapshot) do
    Security::SessionSnapshot.new(
      access_token:  build_jwt(exp: Time.now.to_i + 30),   # 30 s remaining
      refresh_token: "rt",
      csrf_token:    "csrf",
      principal:     Security::Principal.guest.tap { |p| p.instance_variable_set(:@id, "u1") }
    )
  end

  let(:fresh_snapshot) do
    Security::SessionSnapshot.new(
      access_token:  build_jwt(exp: Time.now.to_i + 900),
      refresh_token: "rt2",
      csrf_token:    "csrf2",
      principal:     Security::Principal.guest.tap { |p| p.instance_variable_set(:@id, "u1") }
    )
  end

  describe "#call" do
    it "returns :refreshed and persists new snapshot when token is about to expire" do
      session = build_session_with(expiring_snapshot)
      allow(provider).to receive(:refresh).and_return(fresh_snapshot)

      result = use_case.call(session:)

      expect(result).to eq(:refreshed)
      expect(session[Security::SessionStore::ACCESS_TOKEN_KEY]).to include(".")
    end

    it "returns :not_needed when token has plenty of time remaining" do
      snapshot = Security::SessionSnapshot.new(
        access_token:  build_jwt(exp: Time.now.to_i + 400),
        refresh_token: "rt",
        csrf_token:    "csrf",
        principal:     Security::Principal.guest.tap { |p| p.instance_variable_set(:@id, "u1") }
      )
      session = build_session_with(snapshot)
      expect(provider).not_to receive(:refresh)

      expect(use_case.call(session:)).to eq(:not_needed)
    end

    it "raises RefreshFailedError when provider raises AuthenticationError" do
      session = build_session_with(expiring_snapshot)
      allow(provider).to receive(:refresh).and_raise(Backend::Errors::AuthenticationError)

      expect { use_case.call(session:) }
        .to raise_error(Security::RefreshSession::RefreshFailedError)
    end

    it "returns :not_needed for guest session" do
      session = {}
      expect(use_case.call(session:)).to eq(:not_needed)
    end
  end

  def build_jwt(exp:)
    payload = Base64.urlsafe_encode64({ "exp" => exp, "user_session" => { "id" => "u1" } }.to_json, padding: false)
    "header.#{payload}.sig"
  end

  def build_session_with(snapshot)
    session = {}
    Security::SessionStore.new(session:).persist!(snapshot:)
    session
  end
end
```

### Addition to `spec/requests/auth_sessions_spec.rb`

```ruby
context "token refresh" do
  it "redirects to login when refresh_token is expired" do
    # Sign in to get a session
    post "/en/session", params: { username: "admin.s", password: "test" }

    # Simulate expired access_token (manual session manipulation)
    allow_any_instance_of(Security::RefreshSession)
      .to receive(:call).and_raise(Security::RefreshSession::RefreshFailedError, "expired")

    get "/en/workspace"

    expect(response).to redirect_to("/en/session/new")
    follow_redirect!
    expect(response.body).to include("session has expired")
  end
end
```

---

## Validation gate

```bash
bin/rubocop
bin/rspec spec/use_cases/security/refresh_session_spec.rb \
          spec/requests/auth_sessions_spec.rb
bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"
```
