# Helper to generate test JWT tokens for API v1 specs.
# These tokens are decoded client-side by SessionSnapshotMapper.from_bearer
# without signature verification (same as the existing mapper approach).

module ApiTokenHelper
  def api_token_for(username: "admin.test", email: "admin@test.com", roles: [], permissions: [])
    header = Base64.urlsafe_encode64('{"alg":"none","typ":"JWT"}', padding: false)
    payload_hash = {
      "type" => "access",
      "user_session" => {
        "id" => "test-#{Digest::SHA256.hexdigest(username).first(12)}",
        "username" => username,
        "email" => email,
        "fullname" => username.tr(".", " ").split.map(&:capitalize).join(" "),
        "roles" => roles,
        "permissions" => permissions,
        "jti" => SecureRandom.uuid
      },
      "iat" => Time.current.to_i,
      "exp" => 1.hour.from_now.to_i
    }
    payload = Base64.urlsafe_encode64(payload_hash.to_json, padding: false)
    "#{header}.#{payload}.unsigned"
  end

  def api_auth_headers(username: "admin.test", email: "admin@test.com", roles: [ "admin" ])
    token = api_token_for(username: username, email: email, roles: roles)
    { "Authorization" => "Bearer #{token}" }
  end

  def api_guest_headers
    {}
  end
end

RSpec.configure do |config|
  config.include ApiTokenHelper, type: :request
end
