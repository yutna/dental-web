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
      raise Errors::UnexpectedResponseError, e.message
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

    def parse_response(response)
      if [ 401, 403 ].include?(response.status)
        raise Errors::AuthenticationError, "Invalid backend credentials"
      end

      unless response.success?
        raise Errors::UnexpectedResponseError, "Backend API request failed with status #{response.status}"
      end

      parsed_body = JSON.parse(response.body.to_s)
      return parsed_body if parsed_body.is_a?(Hash)

      raise Errors::UnexpectedResponseError, "Backend API response must be a JSON object"
    rescue JSON::ParserError => e
      raise Errors::UnexpectedResponseError, "Backend API JSON parse failed: #{e.message}"
    end
  end
end
