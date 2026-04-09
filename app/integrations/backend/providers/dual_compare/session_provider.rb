module Backend
  module Providers
    module DualCompare
      class SessionProvider
        def initialize(
          local_provider: Local::SessionProvider.new,
          remote_provider: Remote::SessionProvider.new
        )
          @local_provider = local_provider
          @remote_provider = remote_provider
        end

        def sign_in(email:, password:)
          local_snapshot = local_provider.sign_in(email:, password:)
          remote_snapshot = remote_provider.sign_in(email:, password:)

          verify_contract!(local_snapshot:, remote_snapshot:)
          local_snapshot
        end

        def sign_out(snapshot)
          local_provider.sign_out(snapshot)
          remote_provider.sign_out(snapshot)
        end

        private

        attr_reader :local_provider, :remote_provider

        def verify_contract!(local_snapshot:, remote_snapshot:)
          return if same_contract?(local_snapshot:, remote_snapshot:)

          raise Errors::ContractMismatchError, "Canonical session contract differs between local and remote providers"
        end

        def same_contract?(local_snapshot:, remote_snapshot:)
          local_principal = local_snapshot.principal
          remote_principal = remote_snapshot.principal

          local_principal.email == remote_principal.email &&
            local_principal.roles == remote_principal.roles &&
            local_principal.permissions == remote_principal.permissions
        end
      end
    end
  end
end
