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
          true
        rescue Errors::ServiceUnavailableError
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
