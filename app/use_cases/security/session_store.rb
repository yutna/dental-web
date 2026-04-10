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
