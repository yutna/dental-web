module Security
  class SessionSnapshot
    attr_reader :access_token, :refresh_token, :csrf_token, :principal

    def self.guest
      new(
        access_token: nil,
        refresh_token: nil,
        csrf_token: nil,
        principal: Principal.guest
      )
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

    # Decodes the JWT exp claim without a gem dependency.
    def access_token_exp
      return nil if access_token.blank?

      payload_b64 = access_token.split(".")[1]
      return nil if payload_b64.blank?

      padding = "=" * ((4 - payload_b64.length % 4) % 4)
      payload = JSON.parse(Base64.urlsafe_decode64(payload_b64 + padding))
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
