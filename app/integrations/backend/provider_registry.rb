module Backend
  class ProviderRegistry
    def initialize(session_provider: nil)
      @session_provider = session_provider
    end

    def session_provider
      return @session_provider if @session_provider

      # Keep tests deterministic without network dependencies.
      return Providers::Local::SessionProvider.new if Rails.env.test?

      Providers::Remote::SessionProvider.new
    end
  end
end
