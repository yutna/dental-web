module Security
  class SessionSnapshot
    attr_reader :access_token, :refresh_token, :principal

    def self.guest
      new(
        access_token: nil,
        refresh_token: nil,
        principal: Principal.guest
      )
    end

    def initialize(access_token:, refresh_token:, principal:)
      @access_token = access_token.presence
      @refresh_token = refresh_token.presence
      @principal = principal || Principal.guest
    end

    def guest?
      principal.guest?
    end

    def to_h
      {
        "access_token" => access_token,
        "refresh_token" => refresh_token,
        "principal" => principal.to_h
      }
    end
  end
end
