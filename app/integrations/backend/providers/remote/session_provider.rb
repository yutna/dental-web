module Backend
  module Providers
    module Remote
      class SessionProvider
        LOGIN_PATH = "/api/v1/auth/login".freeze

        def initialize(http_client: HttpClient.new, mapper: Mappers::SessionSnapshotMapper)
          @http_client = http_client
          @mapper = mapper
        end

        def sign_in(email:, password:)
          payload = http_client.post(LOGIN_PATH, { email:, password: })
          mapper.from_remote(payload)
        end

        def sign_out(_snapshot)
          true
        end

        private

        attr_reader :http_client, :mapper
      end
    end
  end
end
