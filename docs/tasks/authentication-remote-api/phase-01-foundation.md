# Phase 01 — Foundation: Contracts & Seams

## Goal

Extend the Rails BFF domain, session, and HTTP client layers to carry the new fields
and capabilities required by the real Meditech Auth API, **without yet connecting to the
remote API**. All changes in this phase must keep deterministic test seams working and
all existing tests passing.

---

## Scenarios covered

- SessionStore persists and reads `csrf_token` (`@must`)
- SessionStore.clear! removes all token fields including `csrf_token` (`@must`)
- Mapper raises on missing fields (contract guard added to errors) (`@must`)
- CSRF token not in HTML (SessionStore stores it server-side only) (`@must`)

---

## Scope

```
app/domains/security/
  principal.rb            — add username field
  session_snapshot.rb     — add csrf_token field

app/use_cases/security/
  session_store.rb        — add BACKEND_CSRF_TOKEN_KEY; update persist!/read/clear!

app/integrations/backend/
  errors.rb               — add ValidationError, ServiceUnavailableError
  http_client.rb          — add get_authenticated / post_authenticated methods

config/initializers/
  filter_parameter_logging.rb   — add :csrf_token, :access_token, :refresh_token

spec/use_cases/security/
  session_store_spec.rb   (NEW or update if exists)
spec/integrations/backend/
  http_client_spec.rb     (NEW — test authenticated request methods)
```

---

## Implementation detail

### 1. `Security::SessionSnapshot` — add `csrf_token`

```ruby
# app/domains/security/session_snapshot.rb
module Security
  class SessionSnapshot
    attr_reader :access_token, :refresh_token, :csrf_token, :principal

    def self.guest
      new(access_token: nil, refresh_token: nil, csrf_token: nil, principal: Principal.guest)
    end

    def initialize(access_token:, refresh_token:, csrf_token: nil, principal:)
      @access_token  = access_token.presence
      @refresh_token = refresh_token.presence
      @csrf_token    = csrf_token.presence
      @principal     = principal || Principal.guest
    end

    def guest?
      principal.guest?
    end

    # Expose exp from access_token JWT without external gem dependency
    def access_token_exp
      return nil if access_token.blank?

      payload_b64 = access_token.split(".")[1]
      return nil if payload_b64.blank?

      payload = JSON.parse(Base64.urlsafe_decode64(payload_b64 + "=="))
      payload["exp"]
    rescue JSON::ParserError, ArgumentError
      nil
    end

    def to_h
      {
        "access_token"  => access_token,
        "refresh_token" => refresh_token,
        "csrf_token"    => csrf_token,
        "principal"     => principal.to_h
      }
    end
  end
end
```

**Key:** `access_token_exp` decodes the JWT `exp` claim in the BFF without introducing a JWT
gem dependency — Base64 + JSON.parse is sufficient for reading (not verifying) the TTL.

---

### 2. `Security::Principal` — add `username` field

```ruby
# app/domains/security/principal.rb
module Security
  class Principal
    attr_reader :id, :username, :email, :display_name, :roles, :permissions

    def self.guest
      new(id: nil, username: nil, email: nil, display_name: "Guest", roles: [], permissions: [])
    end

    def self.from_h(payload)
      return guest if payload.blank?

      payload = payload.deep_stringify_keys
      new(
        id:           payload["id"],
        username:     payload["username"],
        email:        payload["email"],
        display_name: payload["display_name"] || payload["displayName"] || payload["email"],
        roles:        payload["roles"],
        permissions:  payload["permissions"]
      )
    end

    def initialize(id:, username: nil, email:, display_name:, roles:, permissions:)
      @id           = id&.to_s
      @username     = username&.to_s
      @email        = email&.to_s
      @display_name = display_name&.to_s || email&.to_s
      @roles        = normalize_items(roles)
      @permissions  = normalize_items(permissions)
    end

    def guest?
      id.blank?
    end

    def allowed?(permission)
      permissions.include?(permission.to_s)
    end

    def to_h
      {
        "id"           => id,
        "username"     => username,
        "email"        => email,
        "display_name" => display_name,
        "roles"        => roles,
        "permissions"  => permissions
      }
    end

    private

    def normalize_items(items)
      Array(items).map(&:to_s).reject(&:blank?).uniq.sort
    end
  end
end
```

---

### 3. `Security::SessionStore` — add `csrf_token`

```ruby
# app/use_cases/security/session_store.rb
module Security
  class SessionStore < BaseUseCase
    ACCESS_TOKEN_KEY  = :backend_access_token
    REFRESH_TOKEN_KEY = :backend_refresh_token
    CSRF_TOKEN_KEY    = :backend_csrf_token
    PRINCIPAL_KEY     = :backend_principal

    def initialize(session:)
      @session = session
    end

    def read
      Security::SessionSnapshot.new(
        access_token:  session[ACCESS_TOKEN_KEY],
        refresh_token: session[REFRESH_TOKEN_KEY],
        csrf_token:    session[CSRF_TOKEN_KEY],
        principal:     Security::Principal.from_h(session[PRINCIPAL_KEY])
      )
    end

    def persist!(snapshot:)
      session[ACCESS_TOKEN_KEY]  = snapshot.access_token
      session[REFRESH_TOKEN_KEY] = snapshot.refresh_token
      session[CSRF_TOKEN_KEY]    = snapshot.csrf_token
      session[PRINCIPAL_KEY]     = snapshot.principal.to_h
    end

    def clear!
      session.delete(ACCESS_TOKEN_KEY)
      session.delete(REFRESH_TOKEN_KEY)
      session.delete(CSRF_TOKEN_KEY)
      session.delete(PRINCIPAL_KEY)
    end

    private

    attr_reader :session
  end
end
```

---

### 4. `Backend::Errors` — add new error classes

```ruby
# app/integrations/backend/errors.rb
module Backend
  module Errors
    class AuthenticationError      < StandardError; end
    class UnexpectedResponseError  < StandardError; end
    class ContractMismatchError    < StandardError; end
    class ValidationError          < StandardError; end   # NEW — 4xx validation failure from API
    class ServiceUnavailableError  < StandardError; end   # NEW — network / 5xx
  end
end
```

---

### 5. `Backend::HttpClient` — authenticated request methods

Add two new public methods alongside the existing `post`. Do not modify existing `post`.

```ruby
# app/integrations/backend/http_client.rb (additions)

def get_authenticated(path, access_token:, csrf_token:)
  response = connection.get(path) do |request|
    apply_auth_headers(request, access_token:, csrf_token:)
  end
  parse_response(response)
rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
  raise Errors::ServiceUnavailableError, e.message
end

def post_authenticated(path, payload, access_token:, csrf_token:)
  response = connection.post(path) do |request|
    request.headers["Content-Type"] = "application/json"
    apply_auth_headers(request, access_token:, csrf_token:)
    request.body = JSON.generate(payload)
  end
  parse_response(response)
rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
  raise Errors::ServiceUnavailableError, e.message
end

private

def apply_auth_headers(request, access_token:, csrf_token:)
  request.headers["Authorization"] = "Bearer #{access_token}"
  request.headers["x-csrf-token"]  = csrf_token.to_s
end
```

Also update `parse_response` to:

- Return `{}` for empty body (200/204 from logout)
- Map HTTP 400 to `Errors::ValidationError`
- Map connection errors to `Errors::ServiceUnavailableError`

```ruby
def parse_response(response)
  if response.status == 401 || response.status == 403
    raise Errors::AuthenticationError, "Invalid backend credentials (#{response.status})"
  end

  if response.status == 400
    raise Errors::ValidationError, "Backend API validation error: #{response.body}"
  end

  unless response.success?
    raise Errors::UnexpectedResponseError, "Backend API returned #{response.status}"
  end

  return {} if response.body.blank?

  parsed = JSON.parse(response.body.to_s)
  return parsed if parsed.is_a?(Hash)

  raise Errors::UnexpectedResponseError, "Backend API response must be a JSON object"
rescue JSON::ParserError => e
  raise Errors::UnexpectedResponseError, "JSON parse failed: #{e.message}"
end
```

---

### 6. `filter_parameter_logging.rb` — token redaction

Add sensitive backend token fields to the filter list:

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn,
  :access_token, :refresh_token, :csrf_token   # ← add these
]
```

---

## Risk notes

- `SessionSnapshot#access_token_exp` decodes without signature verification — this is
  intentional; the BFF trusts the token it received from the API and only reads `exp`
  for scheduling purposes. Signature verification occurs at the API layer.
- The JWT Base64 decode pads the string with `"=="` to handle non-padded URLs; test
  both padded and non-padded tokens in specs.
- `Local::SessionProvider` creates `SessionSnapshot` without `csrf_token` — this is
  fine; after this phase, `csrf_token` defaults to `nil` which is valid for test seams.

---

## Tests to add/update in this phase

### `spec/use_cases/security/session_store_spec.rb`

```ruby
RSpec.describe Security::SessionStore do
  describe "#persist! and #read" do
    it "round-trips csrf_token" do
      session = {}
      snapshot = Security::SessionSnapshot.new(
        access_token: "at", refresh_token: "rt", csrf_token: "csrf123",
        principal: Security::Principal.guest
      )
      store = described_class.new(session:)
      store.persist!(snapshot:)

      read = store.read
      expect(read.csrf_token).to eq("csrf123")
    end
  end

  describe "#clear!" do
    it "removes csrf_token from session" do
      session = { Security::SessionStore::CSRF_TOKEN_KEY => "csrf123" }
      described_class.new(session:).clear!

      expect(session[Security::SessionStore::CSRF_TOKEN_KEY]).to be_nil
    end
  end
end
```

### `spec/integrations/backend/http_client_spec.rb`

```ruby
RSpec.describe Backend::HttpClient do
  describe "#get_authenticated" do
    it "sends Authorization and x-csrf-token headers" do
      stub = stub_request(:get, /\/auth\/v1\/profile/)
        .with(headers: { "Authorization" => "Bearer mytoken", "x-csrf-token" => "mycsrf" })
        .to_return(status: 200, body: '{"data":{}}')

      client = described_class.new(base_url: "https://example.com")
      client.get_authenticated("/auth/v1/profile", access_token: "mytoken", csrf_token: "mycsrf")

      expect(stub).to have_been_requested
    end
  end

  describe "#parse_response" do
    it "returns empty hash for blank body (logout 200)" do
      stub_request(:post, /logout/).to_return(status: 200, body: "")
      client = described_class.new(base_url: "https://example.com")
      result = client.post_authenticated("/auth/v1/logout", {}, access_token: "at", csrf_token: "cs")
      expect(result).to eq({})
    end
  end
end
```

### `spec/domains/security/session_snapshot_spec.rb`

```ruby
RSpec.describe Security::SessionSnapshot do
  describe "#access_token_exp" do
    it "returns the exp claim from a real JWT" do
      # Use a real-shaped JWT with known exp
      jwt = "eyJhbGci.eyJleHAiOjE3NzU4MTMzMjN9.sig"
      snapshot = described_class.new(access_token: jwt, refresh_token: nil, principal: Security::Principal.guest)
      expect(snapshot.access_token_exp).to eq(1775813323)
    end

    it "returns nil for blank access_token" do
      snapshot = described_class.new(access_token: nil, refresh_token: nil, principal: Security::Principal.guest)
      expect(snapshot.access_token_exp).to be_nil
    end
  end
end
```

---

## Validation gate

```bash
bin/rubocop
bin/rspec spec/use_cases/security/session_store_spec.rb \
          spec/integrations/backend/http_client_spec.rb \
          spec/domains/security/session_snapshot_spec.rb
bin/rspec --exclude-pattern "spec/system/**/*_spec.rb"
```

All existing tests must remain green.
