unless Rails.env.test?
  required_backend_envs = %w[
    BACKEND_API_BASE_URL
    BACKEND_API_OPEN_TIMEOUT
    BACKEND_API_READ_TIMEOUT
  ].freeze

  missing_envs = required_backend_envs.select { |key| ENV[key].to_s.strip.empty? }

  if missing_envs.any?
    raise ArgumentError, "Missing required environment variable(s): #{missing_envs.join(", ")}"
  end
end
