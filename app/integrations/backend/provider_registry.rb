module Backend
  class ProviderRegistry
    def initialize(mode: Rails.configuration.x.bff.provider_mode)
      @mode = mode
    end

    def session_provider
      case mode
      when "local"
        Providers::Local::SessionProvider.new
      when "remote"
        Providers::Remote::SessionProvider.new
      when "dual_compare"
        Providers::DualCompare::SessionProvider.new
      else
        raise ArgumentError, "Unsupported BFF provider mode: #{mode}"
      end
    end

    private

    attr_reader :mode
  end
end
