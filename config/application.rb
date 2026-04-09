require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DentalWeb
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.i18n.available_locales = %i[en th]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = true
    config.x.bff.provider_mode = ENV.fetch("BFF_PROVIDER_MODE", "local")
    config.x.backend_api.base_url = ENV.fetch("BACKEND_API_BASE_URL", "http://localhost:3001")
    config.x.backend_api.open_timeout = ENV.fetch("BACKEND_API_OPEN_TIMEOUT", 2).to_i
    config.x.backend_api.read_timeout = ENV.fetch("BACKEND_API_READ_TIMEOUT", 5).to_i

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: true
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
