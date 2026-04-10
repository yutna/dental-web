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
