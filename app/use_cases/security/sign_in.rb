module Security
  class SignIn < BaseUseCase
    class InvalidCredentialsError < StandardError; end

    def initialize(provider_registry: Backend::ProviderRegistry.new)
      @provider_registry = provider_registry
    end

    def call(email:, password:)
      snapshot = provider_registry.session_provider.sign_in(email:, password:)
      ensure_workspace_access!(snapshot)
      snapshot
    rescue Backend::Errors::AuthenticationError => e
      raise InvalidCredentialsError, e.message
    end

    private

    attr_reader :provider_registry

    def ensure_workspace_access!(snapshot)
      return if snapshot.principal.allowed?("workspace:read")

      raise Backend::Errors::ContractMismatchError, "Missing workspace:read permission in canonical contract"
    end
  end
end
