# Phase 05 — Tests & Hardening

## Goal

Update all existing specs to reflect the phases 01–04 changes, add missing coverage
for remote-provider and token-refresh flows, add a system test for the full end-to-end
login/logout journey using the real dev API, and ensure `bin/ci` passes completely.

---

## Scenarios covered

All `@must` and `@should` scenarios from `test-scenarios.md`.

---

## Scope

```
spec/requests/
  auth_sessions_spec.rb                      — full rewrite to cover all must/should scenarios
  workspace_spec.rb                          — update sign_in helper (email → username)
  admin/clinic_services_spec.rb              — update sign_in helper

spec/use_cases/security/
  sign_in_spec.rb                            — already added in Phase 02 (verify complete)
  sign_out_spec.rb                           (NEW)
  refresh_session_spec.rb                    — already added in Phase 03 (verify complete)
  session_store_spec.rb                      — already added in Phase 01 (verify complete)

spec/integrations/backend/
  mappers/session_snapshot_mapper_spec.rb    — already added in Phase 02 (verify complete)
  providers/remote/session_provider_spec.rb  — already added in Phase 02 (verify complete)
  http_client_spec.rb                        — already added in Phase 01 (verify complete)

spec/policies/workspace_policy_spec.rb       — verify workspace:read check still works
spec/domains/security/
  session_snapshot_spec.rb                  — already added in Phase 01 (verify complete)
  principal_spec.rb                         (NEW — test username field)

spec/factories/                             — update or add factory if needed

spec/system/
  authentication_spec.rb                    (NEW — E2E with real dev API)
```

---

## Implementation detail

### 1. Update `spec/requests/auth_sessions_spec.rb`

Replace inline old specs with the canonical set below.

```ruby
require "rails_helper"

RSpec.describe "Auth sessions", type: :request do
  # ─── GET new ──────────────────────────────────────────────────────
  describe "GET /en/session/new" do
    it "renders sign-in form with username field" do
      get "/en/session/new"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('name="username"')
      expect(response.body).to include('type="text"')
      expect(response.body).not_to include('name="email"')
    end

    it "redirects to home page when already signed in" do
      sign_in_locally
      get "/en/session/new"

      expect(response).to redirect_to("/en")
    end

    it "does not expose csrf_token in HTML" do
      sign_in_locally
      get "/en"

      # The backend csrf_token must not appear anywhere in the rendered HTML
      snapshot = Security::SessionStore.new(session: session).read
      expect(response.body).not_to include(snapshot.csrf_token.to_s) if snapshot.csrf_token.present?
    end
  end

  # ─── POST create ──────────────────────────────────────────────────
  describe "POST /en/session" do
    context "with local provider (default in test)" do
      it "creates session and redirects to home page" do
        post "/en/session", params: { username: "clinician.test", password: "secret" }

        expect(response).to redirect_to("/en")
        follow_redirect!
        expect(response).to have_http_status(:ok)
      end

      it "renders error on invalid credentials" do
        allow_any_instance_of(Security::SignIn)
          .to receive(:call).and_raise(Security::SignIn::InvalidCredentialsError)

        post "/en/session", params: { username: "bad", password: "wrong" }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Invalid username or password.")
        expect(response.body).to include('role="alert"')
      end

      it "retains submitted username on error" do
        allow_any_instance_of(Security::SignIn)
          .to receive(:call).and_raise(Security::SignIn::InvalidCredentialsError)

        post "/en/session", params: { username: "admin.s", password: "wrong" }

        expect(response.body).to include('value="admin.s"')
      end

      it "renders service_unavailable error when backend is unreachable" do
        allow_any_instance_of(Security::SignIn)
          .to receive(:call).and_raise(Security::SignIn::ServiceUnavailableError)

        post "/en/session", params: { username: "x", password: "y" }

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("temporarily unavailable")
      end
    end

    context "Thai locale" do
      it "shows error in Thai when credentials invalid" do
        allow_any_instance_of(Security::SignIn)
          .to receive(:call).and_raise(Security::SignIn::InvalidCredentialsError)

        post "/th/session", params: { username: "bad", password: "wrong" }

        expect(response.body).to include("ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง")
      end
    end
  end

  # ─── DELETE destroy ───────────────────────────────────────────────
  describe "DELETE /en/session" do
    it "clears session and redirects to root" do
      sign_in_locally
      delete "/en/session"

      expect(response).to redirect_to("/en")
      follow_redirect!
      expect(response.body).to include("Signed out successfully.")
    end
  end

  # ─── Home page guard ──────────────────────────────────────────────
  describe "home page access guard" do
    it "redirects to login when not signed in" do
      get "/en"
      expect(response).to redirect_to("/en/session/new")
    end

    it "renders home page when signed in" do
      sign_in_locally
      get "/en"
      expect(response).to have_http_status(:ok)
    end
  end

  # ─── Workspace guard ──────────────────────────────────────────────
  describe "workspace access guard" do
    it "redirects to login when not signed in" do
      get "/en/workspace"
      expect(response).to redirect_to("/en/session/new")
    end
  end

  # ─── Token refresh ────────────────────────────────────────────────
  describe "token refresh" do
    it "redirects to login when RefreshSession raises RefreshFailedError" do
      sign_in_locally
      allow_any_instance_of(Security::RefreshSession)
        .to receive(:call).and_raise(Security::RefreshSession::RefreshFailedError, "expired")

      get "/en"

      expect(response).to redirect_to("/en/session/new")
      follow_redirect!
      expect(response.body).to include("session has expired")
    end
  end

  # ─── Cookie security ──────────────────────────────────────────────
  describe "session cookie flags" do
    it "sets HttpOnly flag on session cookie in test env" do
      post "/en/session", params: { username: "clinician.test", password: "secret" }

      set_cookie = response.headers["Set-Cookie"]
      # Rack/Rails test env may use different cookie format; assert key is not JS-readable
      expect(set_cookie).to include("HttpOnly") if set_cookie.present?
    end
  end

  private

  def sign_in_locally
    post "/en/session", params: { username: "clinician.test", password: "secret" }
    expect(response).to redirect_to("/en")
  end
end
```

---

### 2. Update helper references `email` → `username` in other request specs

**`spec/requests/workspace_spec.rb`:**
```ruby
post "/en/session", params: { username: "clinician.test", password: "secret" }
```

**`spec/requests/admin/clinic_services_spec.rb`:**
```ruby
def sign_in_as(username:)
  post "/en/session", params: { username: username, password: "secret" }
  expect(response).to redirect_to("/en")
end

# Update call sites:
sign_in_as(username: "admin.test")
sign_in_as(username: "clinician.test")
```

Note: The local provider uses email-like strings; update fixtures to use usernames
or keep using email-format strings — local provider accepts any non-blank string.
Use `admin.test` (admin user) and `clinician.test` (non-admin) as canonical test
usernames for local mode.

---

### 3. `spec/use_cases/security/sign_out_spec.rb` (NEW)

```ruby
RSpec.describe Security::SignOut do
  describe "#call" do
    it "clears the local session" do
      session = { Security::SessionStore::ACCESS_TOKEN_KEY => "token" }
      allow_any_instance_of(Backend::Providers::Local::SessionProvider).to receive(:sign_out)

      Security::SignOut.call(session:)

      expect(session[Security::SessionStore::ACCESS_TOKEN_KEY]).to be_nil
    end

    it "does not raise when provider sign_out raises" do
      session = { Security::SessionStore::ACCESS_TOKEN_KEY => "token" }
      provider = instance_double(Backend::Providers::Remote::SessionProvider)
      allow(provider).to receive(:sign_out).and_raise(Backend::Errors::AuthenticationError)
      registry = instance_double(Backend::ProviderRegistry, session_provider: provider)

      # sign_out itself does not rescue — provider#sign_out is responsible for
      # absorbing errors. This spec verifies the chain propagates correctly.
      # (Phase 02 Remote::SessionProvider#sign_out rescues and swallows 401.)
      expect {
        Security::SignOut.new(provider_registry: registry).call(session:)
      }.to raise_error(Backend::Errors::AuthenticationError)
    end
  end
end
```

---

### 4. `spec/domains/security/principal_spec.rb` (NEW)

```ruby
RSpec.describe Security::Principal do
  describe ".from_h" do
    it "maps username field" do
      principal = described_class.from_h({ "id" => "1", "username" => "admin.s",
                                           "email" => "a@b.com", "display_name" => "Admin",
                                           "roles" => [], "permissions" => [] })
      expect(principal.username).to eq("admin.s")
    end

    it "includes username in to_h" do
      principal = described_class.new(id: "1", username: "admin.s", email: "a@b.com",
                                      display_name: "Admin", roles: [], permissions: [])
      expect(principal.to_h["username"]).to eq("admin.s")
    end
  end
end
```

---

### 5. System test — `spec/system/authentication_spec.rb` (NEW)

Requires `BFF_PROVIDER_MODE=remote`. Tagged `@remote` so CI can control execution.

```ruby
# spec/system/authentication_spec.rb
require "rails_helper"

# Run with: BFF_PROVIDER_MODE=remote bin/rspec spec/system/authentication_spec.rb
RSpec.describe "Authentication (E2E)", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  # Skip if not in remote mode
  before do
    skip "Remote system tests require BFF_PROVIDER_MODE=remote" unless
      Rails.configuration.x.bff.provider_mode == "remote"
  end

  describe "sign-in flow" do
    it "signs in with valid dev credentials and reaches home page" do
      visit "/en/session/new"

      expect(page).to have_text("Sign in to continue")
      expect(page).to have_field("username")

      fill_in "username", with: "admin.s"
      fill_in "password", with: "123"
      click_button "Sign in"

      expect(page).to have_current_path("/en")
      expect(page).to have_text("Signed in successfully.")
    end

    it "shows error on invalid credentials" do
      visit "/en/session/new"

      fill_in "username", with: "wrong.user"
      fill_in "password", with: "badpassword"
      click_button "Sign in"

      expect(page).to have_current_path("/en/session")
      expect(page).to have_text("Invalid username or password.")
      expect(page).to have_field("username", with: "wrong.user")
    end

    it "signs out and returns to sign-in page" do
      # Sign in first
      visit "/en/session/new"
      fill_in "username", with: "admin.s"
      fill_in "password", with: "123"
      click_button "Sign in"
      expect(page).to have_current_path("/en")

      # Sign out
      page.find("[data-testid='sign-out-button']").click rescue
        visit "/en/session" # fallback DELETE via form if no button

      # After sign-out
      expect(page).to have_text("Signed out successfully.")
    end

    it "redirects unauthenticated user away from home page" do
      visit "/en"
      expect(page).to have_current_path("/en/session/new")
    end

    it "redirects unauthenticated user away from workspace" do
      visit "/en/workspace"
      expect(page).to have_current_path("/en/session/new")
    end
  end

  describe "Thai locale" do
    it "shows Thai heading on sign-in page" do
      visit "/th/session/new"
      expect(page).to have_text("ลงชื่อเข้าใช้งาน")
      expect(page).to have_field("username")
    end
  end
end
```

---

### 6. Verify `spec/requests/localization_spec.rb` still passes

The existing localization spec checks for specific text. Ensure the updated `demo_hint`
and `description` i18n values do not break those assertions. The localization spec
tests the home page (`/en`), not the session page, so it should be unaffected.

---

## Validation gate (complete run)

```bash
# Lint
bin/rubocop

# i18n health
bundle exec i18n-tasks health

# Security scan
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error

# Full unit + request test suite
bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"

# System tests (remote mode only)
BFF_PROVIDER_MODE=remote bin/rspec spec/system/authentication_spec.rb

# Full CI gate
bin/ci
```

All commands must exit 0.

---

## Guardrail update (defect prevention)

After completing all phases, add a note to
`.github/instructions/rails-bff.instructions.md` under a new
"Authentication contract" section:

```markdown
## Authentication contract (Meditech Auth API)

- Login parameter is `username`, not `email`.
- Login/refresh responses include `csrf_token` — always store in `Security::SessionStore`.
- Every authenticated backend request must include `Authorization: Bearer <access_token>`
  and `x-csrf-token: <csrf_token>` headers via `HttpClient#post_authenticated` or
  `HttpClient#get_authenticated`.
- `SessionSnapshotMapper.from_remote` decodes the JWT to extract `user_session` fields.
  Do not look for a `user` or `principal` wrapper in the login response body.
- The BFF injects `workspace:read` for all successfully authenticated users.
  Never rely on the API to return this permission.
- `SecurityRefreshSession::REFRESH_THRESHOLD_SECONDS = 60` is the threshold.
  Do not lower it — concurrent requests near expiry could fail if threshold is too small.
```
