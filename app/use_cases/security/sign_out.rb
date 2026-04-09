module Security
  class SignOut < BaseUseCase
    def initialize(provider_registry: Backend::ProviderRegistry.new)
      @provider_registry = provider_registry
    end

    def call(session:)
      session_store = SessionStore.new(session:)
      snapshot = session_store.read
      provider_registry.session_provider.sign_out(snapshot)
      session_store.clear!
    end

    private

    attr_reader :provider_registry
  end
end
