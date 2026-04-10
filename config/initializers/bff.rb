base_url = Rails.configuration.x.backend_api.base_url.to_s.strip

if base_url.empty?
  raise ArgumentError, "BACKEND_API_BASE_URL is required"
end
