module Security
  class RefreshSession < BaseUseCase
    class RefreshFailedError < StandardError; end

    REFRESH_THRESHOLD_SECONDS = 60

    def initialize(provider_registry: Backend::ProviderRegistry.new)
      @provider_registry = provider_registry
    end

    # Returns :refreshed, :not_needed, or raises RefreshFailedError
    def call(session:)
      store    = SessionStore.new(session:)
      snapshot = store.read

      return :not_needed if snapshot.guest?
      return :not_needed unless needs_refresh?(snapshot)

      new_snapshot = provider_registry.session_provider.refresh(snapshot)
      store.persist!(snapshot: new_snapshot)
      :refreshed
    rescue Backend::Errors::AuthenticationError,
           Backend::Errors::ValidationError,
           Backend::Errors::ServiceUnavailableError => e
      raise RefreshFailedError, e.message
    end

    private

    attr_reader :provider_registry

    def needs_refresh?(snapshot)
      return true if snapshot.refresh_token.blank?

      exp = snapshot.access_token_exp
      return false if exp.nil?

      Time.now.to_i >= (exp - REFRESH_THRESHOLD_SECONDS)
    end
  end
end
