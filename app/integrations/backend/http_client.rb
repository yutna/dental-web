require "json"

module Backend
  class HttpClient
    def initialize(
      base_url: Rails.configuration.x.backend_api.base_url,
      open_timeout: Rails.configuration.x.backend_api.open_timeout,
      read_timeout: Rails.configuration.x.backend_api.read_timeout
    )
      @base_url = base_url
      @open_timeout = open_timeout
      @read_timeout = read_timeout
    end

    def post(path, payload)
      response = connection.post(path) do |request|
        request.headers["Content-Type"] = "application/json"
        request.body = JSON.generate(payload)
      end
      parse_response(response)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      raise Errors::ServiceUnavailableError, e.message
    end

    def get_authenticated(path, access_token:, csrf_token:)
      response = connection.get(path) do |request|
        apply_auth_headers(request, access_token:, csrf_token:)
      end
      parse_response(response)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      raise Errors::ServiceUnavailableError, e.message
    end

    def post_authenticated(path, payload, access_token:, csrf_token:)
      response = connection.post(path) do |request|
        request.headers["Content-Type"] = "application/json"
        apply_auth_headers(request, access_token:, csrf_token:)
        request.body = JSON.generate(payload)
      end
      parse_response(response)
    rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
      raise Errors::ServiceUnavailableError, e.message
    end

    private

    attr_reader :base_url, :open_timeout, :read_timeout

    def connection
      @connection ||= Faraday.new(url: base_url) do |faraday|
        faraday.request :retry, max: 2, interval: 0.2, backoff_factor: 2
        faraday.options.timeout = read_timeout
        faraday.options.open_timeout = open_timeout
        faraday.adapter Faraday.default_adapter
      end
    end

    def apply_auth_headers(request, access_token:, csrf_token:)
      request.headers["Authorization"] = "Bearer #{access_token}"
      request.headers["x-csrf-token"]  = csrf_token.to_s
    end

    def parse_response(response)
      if [ 401, 403 ].include?(response.status)
        raise Errors::AuthenticationError, "Invalid backend credentials (#{response.status})"
      end

      if response.status == 400
        raise Errors::ValidationError, "Backend API validation error: #{response.body}"
      end

      unless response.success?
        raise Errors::UnexpectedResponseError, "Backend API returned #{response.status}"
      end

      return {} if response.body.blank?

      parsed = JSON.parse(response.body.to_s)
      return parsed if parsed.is_a?(Hash)

      raise Errors::UnexpectedResponseError, "Backend API response must be a JSON object"
    rescue JSON::ParserError => e
      raise Errors::UnexpectedResponseError, "JSON parse failed: #{e.message}"
    end
  end
end
