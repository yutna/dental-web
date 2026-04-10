module Backend
  module Providers
    module DualCompare
      class SessionProvider
        def initialize(
          local_provider: Local::SessionProvider.new,
          remote_provider: Remote::SessionProvider.new,
          reporter: ContractMismatchReporter.new
        )
          @local_provider = local_provider
          @remote_provider = remote_provider
          @reporter = reporter
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

        attr_reader :local_provider, :remote_provider, :reporter

        def verify_contract!(local_snapshot:, remote_snapshot:)
          return if same_contract?(local_snapshot:, remote_snapshot:)

          report_path = write_mismatch_report(local_snapshot:, remote_snapshot:)
          raise Errors::ContractMismatchError, "Canonical session contract differs between local and remote providers (report: #{report_path})"
        end

        def same_contract?(local_snapshot:, remote_snapshot:)
          local_principal = local_snapshot.principal
          remote_principal = remote_snapshot.principal

          local_principal.email == remote_principal.email &&
            local_principal.roles == remote_principal.roles &&
            local_principal.permissions == remote_principal.permissions
        end

        def write_mismatch_report(local_snapshot:, remote_snapshot:)
          reporter.write(local_snapshot:, remote_snapshot:)
        rescue SystemCallError, IOError => e
          "unavailable (#{e.class}: #{e.message})"
        end
      end
    end
  end
end
