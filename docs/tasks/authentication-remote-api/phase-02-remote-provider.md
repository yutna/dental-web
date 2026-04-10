# Phase 02 — Remote Provider Alignment

## Goal

Fix the `Remote::SessionProvider` and `SessionSnapshotMapper` to match the real
Meditech Auth API contract. After this phase, runtime BFF authentication
should produce a functional login, a correct session snapshot, a real logout API call,
and a working token refresh API call (the full refresh *flow* is wired in Phase 03).

---

## Scenarios covered

- Successful login → home page (`@must`)
- Sign out calls backend logout (`@must`)
- Mapper extracts principal correctly (`@must`)
- Mapper raises on missing access_token / email (`@must`)
- x-csrf-token header on auth requests (`@must`)
- Invalid credentials 401 (`@must`)
- API unreachable / 5xx (`@must`)

---

## Scope

```
app/integrations/backend/
  mappers/session_snapshot_mapper.rb              — rewrite from_remote for real API shape
  providers/remote/session_provider.rb            — fix login, add logout + refresh

app/controllers/
  home_controller.rb                              — add before_action :require_signed_in!
  auth/sessions_controller.rb                     — fix username param; redirect to root_path

app/use_cases/security/
  sign_in.rb                                      — fix call signature (username not email);
                                                    fix workspace permission check

spec/integrations/backend/
  mappers/session_snapshot_mapper_spec.rb (NEW)
  providers/remote/session_provider_spec.rb (NEW)
spec/use_cases/security/
  sign_in_spec.rb (NEW)
```

---

## Implementation detail

### 1. `SessionSnapshotMapper.from_remote` — rewrite for real API

The real login and refresh endpoints return:

```json
{ "access_token": "...", "refresh_token": "...", "csrf_token": "..." }
```

The `user_session` data lives **inside the JWT**, not in the response body.
Decode the JWT to extract user fields — same approach as `SessionSnapshot#access_token_exp`.

```ruby
# app/integrations/backend/mappers/session_snapshot_mapper.rb
module Backend
  module Mappers
    class SessionSnapshotMapper
      class << self
        # Called after login or refresh — payload is { access_token, refresh_token, csrf_token }
        def from_remote(payload)
          payload = payload.to_h.deep_stringify_keys

          access_token  = payload["access_token"]
          refresh_token = payload["refresh_token"]
          csrf_token    = payload["csrf_token"]

          if access_token.blank?
            raise Errors::UnexpectedResponseError, "Remote auth payload missing access_token"
          end

          user_session = decode_jwt_payload(access_token)["user_session"].presence || {}
          email        = user_session["email"]

          if email.blank?
            raise Errors::UnexpectedResponseError, "Remote auth JWT missing user_session.email"
          end

          principal = Security::Principal.new(
            id:           user_session["id"],
            username:     user_session["username"],
            email:        email,
            display_name: build_display_name(user_session),
            roles:        Array(user_session["roles"]),
            # Inject workspace:read — any successfully authenticated user can access workspace
            permissions:  inject_bff_permissions(user_session)
          )

          Security::SessionSnapshot.new(
            access_token:  access_token,
            refresh_token: refresh_token,
            csrf_token:    csrf_token,
            principal:     principal
          )
        end

        private

        def decode_jwt_payload(token)
          segments = token.to_s.split(".")
          return {} unless segments.length >= 2

          JSON.parse(Base64.urlsafe_decode64(segments[1] + "=="))
        rescue JSON::ParserError, ArgumentError
          {}
        end

        def build_display_name(user_session)
          fullname = user_session["fullname"].presence
          return fullname if fullname

          [user_session["first_name_thai"], user_session["last_name_thai"]].compact.join(" ").presence ||
            [user_session["first_name_eng"], user_session["last_name_eng"]].compact.join(" ").presence ||
            user_session["username"] ||
            user_session["email"]
        end

        def inject_bff_permissions(user_session)
          # workspace:read is granted to all authenticated users from this system
          permissions = ["workspace:read"]
          # Future: map remote admin role → admin:access when API provides it
          api_roles = Array(user_session["roles"]).map(&:to_s)
          permissions << "admin:access" if api_roles.include?("admin")
          permissions
        end
      end
    end
  end
end
```

---

### 2. `Remote::SessionProvider` — fix all three operations

```ruby
# app/integrations/backend/providers/remote/session_provider.rb
module Backend
  module Providers
    module Remote
      class SessionProvider
        LOGIN_PATH   = "/auth/v1/login".freeze
        LOGOUT_PATH  = "/auth/v1/logout".freeze
        REFRESH_PATH = "/auth/v1/refresh".freeze

        def initialize(http_client: HttpClient.new, mapper: Mappers::SessionSnapshotMapper)
          @http_client = http_client
          @mapper      = mapper
        end

        def sign_in(username:, password:)
          payload = http_client.post(LOGIN_PATH, { username:, password: })
          mapper.from_remote(payload)
        rescue Errors::AuthenticationError => e
          raise Errors::AuthenticationError, e.message
        rescue Faraday::ConnectionFailed, Faraday::TimeoutError, Errors::ServiceUnavailableError => e
          raise Errors::ServiceUnavailableError, e.message
        end

        def sign_out(snapshot)
          return if snapshot.guest? || snapshot.access_token.blank?

          http_client.post_authenticated(
            LOGOUT_PATH,
            {},
            access_token: snapshot.access_token,
            csrf_token:   snapshot.csrf_token
          )
        rescue Errors::AuthenticationError
          # Token already expired — Redis session gone; treat as already logged out
          true
        rescue Errors::ServiceUnavailableError
          # Best-effort: log but do not block local session clear
          Rails.logger.warn("[Security::SignOut] Backend logout unreachable; clearing local session anyway")
          true
        end

        def refresh(snapshot)
          payload = http_client.post_authenticated(
            REFRESH_PATH,
            { refresh_token: snapshot.refresh_token },
            access_token: snapshot.access_token,
            csrf_token:   snapshot.csrf_token
          )
          mapper.from_remote(payload)
        end

        private

        attr_reader :http_client, :mapper
      end
    end
  end
end
```

**Key changes from current state:**

- `sign_in` uses `username:` (not `email:`)
- `LOGIN_PATH` is `/auth/v1/login` (not `/api/v1/auth/login`)
- `sign_out` calls `POST /auth/v1/logout` with auth headers; ignores 401 (best-effort)
- `refresh` is a new method calling `POST /auth/v1/refresh`

---

### 3. `Security::SignIn` — fix call signature and permission check

```ruby
# app/use_cases/security/sign_in.rb
module Security
  class SignIn < BaseUseCase
    class InvalidCredentialsError  < StandardError; end
    class ServiceUnavailableError  < StandardError; end

    def initialize(provider_registry: Backend::ProviderRegistry.new)
      @provider_registry = provider_registry
    end

    def call(username:, password:)
      snapshot = provider_registry.session_provider.sign_in(username:, password:)
      ensure_workspace_access!(snapshot)
      snapshot
    rescue Backend::Errors::AuthenticationError => e
      raise InvalidCredentialsError, e.message
    rescue Backend::Errors::ServiceUnavailableError => e
      raise ServiceUnavailableError, e.message
    end

    private

    attr_reader :provider_registry

    def ensure_workspace_access!(snapshot)
      return if snapshot.principal.allowed?("workspace:read")

      raise Backend::Errors::ContractMismatchError,
            "Missing workspace:read permission — mapper misconfiguration"
    end
  end
end
```

**Note:** `SignIn` now takes `username:` not `email:`. The `ensure_workspace_access!`
guard is retained as a contract check — if the mapper fails to inject `workspace:read`,
this will catch it early rather than routing the user to workspace only to get denied.

---

### 4. `Auth::SessionsController` — update param name

```ruby
# app/controllers/auth/sessions_controller.rb (relevant changes)

def create
  snapshot = Security::SignIn.call(
    username: session_params[:username],
    password: session_params[:password]
  )
  Security::SessionStore.new(session:).persist!(snapshot:)
  redirect_to root_path, notice: t("auth.sessions.signed_in")
rescue Security::SignIn::InvalidCredentialsError
  @username   = session_params[:username]
  @auth_error = t("auth.sessions.invalid_credentials")
  render :new, status: :unprocessable_content
rescue Security::SignIn::ServiceUnavailableError
  @username   = session_params[:username]
  @auth_error = t("auth.sessions.service_unavailable")
  render :new, status: :unprocessable_content
rescue Backend::Errors::ContractMismatchError => e
  @username   = session_params[:username]
  @auth_error = t("auth.sessions.contract_mismatch", message: e.message)
  render :new, status: :unprocessable_content
end

private

def session_params
  params.permit(:username, :password)
end
```

---

### 5b. `HomeController` — protect home page

```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  before_action :require_signed_in!

  def index
  end
end
```

Unlike the workspace route (which is also protected via Pundit), the home page is
guarded at the controller level with `require_signed_in!`. This is the first gate
an unauthenticated user will hit on any `/:locale` visit.

---

### 5. Local test seam — add `refresh` helper

```ruby
# app/integrations/backend/providers/local/session_provider.rb (test seam helper)
def refresh(snapshot)
  # Test seam: rotate tokens with new random values
  Security::SessionSnapshot.new(
    access_token:  SecureRandom.hex(24),
    refresh_token: SecureRandom.hex(24),
    csrf_token:    SecureRandom.hex(32),
    principal:     snapshot.principal
  )
end
```

---

## Risk notes

- The mapper decodes JWT without signature verification — this is the correct BFF
  pattern when the BFF issues no tokens of its own. Signature is enforced by the API.
- Empty body on logout (or 401 "session already expired"): both are handled; logout is
  always best-effort and never blocks local session destruction.
- `Backend::Errors::ServiceUnavailableError` must propagate from provider → use_case →
  controller to display the "service unavailable" i18n message.

---

## Tests to add in this phase

### `spec/integrations/backend/mappers/session_snapshot_mapper_spec.rb`

```ruby
RSpec.describe Backend::Mappers::SessionSnapshotMapper do
  let(:valid_payload) do
    {
      "access_token"  => build_jwt(user_session: valid_user_session),
      "refresh_token" => "refresh.jwt.token",
      "csrf_token"    => "abc123"
    }
  end
  let(:valid_user_session) do
    { "id" => "uuid-1", "username" => "admin.s", "email" => "a@b.com",
      "fullname" => "สมชาย ทองดี", "roles" => [], "permissions" => [] }
  end

  describe ".from_remote" do
    it "extracts principal fields from JWT payload" do
      snapshot = described_class.from_remote(valid_payload)
      expect(snapshot.principal.email).to eq("a@b.com")
      expect(snapshot.principal.username).to eq("admin.s")
      expect(snapshot.csrf_token).to eq("abc123")
    end

    it "injects workspace:read permission" do
      snapshot = described_class.from_remote(valid_payload)
      expect(snapshot.principal.allowed?("workspace:read")).to be true
    end

    it "raises UnexpectedResponseError when access_token is blank" do
      expect { described_class.from_remote({}) }
        .to raise_error(Backend::Errors::UnexpectedResponseError, /access_token/)
    end

    it "raises UnexpectedResponseError when email is missing from JWT" do
      no_email_session = valid_user_session.except("email")
      payload = valid_payload.merge("access_token" => build_jwt(user_session: no_email_session))
      expect { described_class.from_remote(payload) }
        .to raise_error(Backend::Errors::UnexpectedResponseError, /email/)
    end
  end

  def build_jwt(user_session:)
    payload = { "user_session" => user_session, "exp" => Time.now.to_i + 900 }
    encoded = Base64.urlsafe_encode64(payload.to_json, padding: false)
    "header.#{encoded}.sig"
  end
end
```

### `spec/integrations/backend/providers/remote/session_provider_spec.rb`

```ruby
RSpec.describe Backend::Providers::Remote::SessionProvider do
  describe "#sign_in" do
    it "posts to /auth/v1/login with username and password" do
      stub = stub_request(:post, /\/auth\/v1\/login/)
        .with(body: { "username" => "admin.s", "password" => "123" })
        .to_return(status: 201, body: login_response_body)

      provider.sign_in(username: "admin.s", password: "123")

      expect(stub).to have_been_requested
    end

    it "raises AuthenticationError on 401" do
      stub_request(:post, /\/auth\/v1\/login/).to_return(status: 401, body: '{}')
      expect { provider.sign_in(username: "x", password: "y") }
        .to raise_error(Backend::Errors::AuthenticationError)
    end
  end

  describe "#sign_out" do
    it "calls POST /auth/v1/logout with bearer and csrf headers" do
      stub = stub_request(:post, /\/auth\/v1\/logout/)
        .with(headers: { "Authorization" => "Bearer at", "x-csrf-token" => "csrf" })
        .to_return(status: 200, body: "")

      snapshot = Security::SessionSnapshot.new(
        access_token: "at", refresh_token: "rt", csrf_token: "csrf",
        principal: Security::Principal.guest
      )
      provider.sign_out(snapshot)

      expect(stub).to have_been_requested
    end

    it "silently succeeds when logout returns 401 (already expired)" do
      stub_request(:post, /\/auth\/v1\/logout/).to_return(status: 401, body: '{}')
      snapshot = build_snapshot
      expect { provider.sign_out(snapshot) }.not_to raise_error
    end
  end

  def provider
    @provider ||= described_class.new(http_client: Backend::HttpClient.new(base_url: "https://example.com"))
  end
end
```

### `spec/use_cases/security/sign_in_spec.rb`

```ruby
RSpec.describe Security::SignIn do
  describe "#call" do
    it "raises InvalidCredentialsError on AuthenticationError from provider" do
      provider = instance_double(Backend::Providers::Remote::SessionProvider)
      allow(provider).to receive(:sign_in).and_raise(Backend::Errors::AuthenticationError)
      registry   = instance_double(Backend::ProviderRegistry, session_provider: provider)
      use_case   = described_class.new(provider_registry: registry)

      expect { use_case.call(username: "x", password: "y") }
        .to raise_error(Security::SignIn::InvalidCredentialsError)
    end

    it "raises ServiceUnavailableError on network failure" do
      provider = instance_double(Backend::Providers::Remote::SessionProvider)
      allow(provider).to receive(:sign_in).and_raise(Backend::Errors::ServiceUnavailableError)
      registry = instance_double(Backend::ProviderRegistry, session_provider: provider)

      expect { described_class.new(provider_registry: registry).call(username: "x", password: "y") }
        .to raise_error(Security::SignIn::ServiceUnavailableError)
    end

    it "raises ContractMismatchError when mapper forgets to inject workspace:read" do
      bad_snapshot = Security::SessionSnapshot.new(
        access_token: "t", refresh_token: "r",
        principal: Security::Principal.new(id: "1", email: "x@y.com",
                                           display_name: "X", roles: [], permissions: [])
      )
      provider = instance_double(Backend::Providers::Remote::SessionProvider)
      allow(provider).to receive(:sign_in).and_return(bad_snapshot)
      registry = instance_double(Backend::ProviderRegistry, session_provider: provider)

      expect { described_class.new(provider_registry: registry).call(username: "x", password: "y") }
        .to raise_error(Backend::Errors::ContractMismatchError)
    end
  end
end
```

---

## Validation gate

```bash
bin/rubocop
bin/rspec spec/integrations/backend/mappers/session_snapshot_mapper_spec.rb \
          spec/integrations/backend/providers/remote/session_provider_spec.rb \
          spec/use_cases/security/sign_in_spec.rb
bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"
```
