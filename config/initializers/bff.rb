valid_modes = %w[local remote dual_compare].freeze
provider_mode = Rails.configuration.x.bff.provider_mode

if valid_modes.exclude?(provider_mode)
  raise ArgumentError, "BFF_PROVIDER_MODE must be one of: #{valid_modes.join(', ')}"
end
