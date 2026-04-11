require "rails_helper"
require "webmock/rspec"

RSpec.describe Backend::HttpClient do
  let(:base_url) { "https://api.test.local" }
  let(:client) do
    described_class.new(
      base_url: base_url,
      open_timeout: 5,
      read_timeout: 10
    )
  end

  before { WebMock.enable! }
  after  { WebMock.disable! }

  # -----------------------------------------------------------------------
  # Successful responses
  # -----------------------------------------------------------------------
  describe "successful requests" do
    it "parses JSON response for post" do
      stub_request(:post, "#{base_url}/test")
        .to_return(status: 200, body: '{"result":"ok"}', headers: { "Content-Type" => "application/json" })

      result = client.post("/test", { data: "value" })
      expect(result).to eq({ "result" => "ok" })
    end

    it "parses JSON response for get_authenticated" do
      stub_request(:get, "#{base_url}/data")
        .to_return(status: 200, body: '{"items":[]}', headers: { "Content-Type" => "application/json" })

      result = client.get_authenticated("/data", access_token: "tok", csrf_token: "csrf")
      expect(result).to eq({ "items" => [] })
    end

    it "returns empty hash for blank body" do
      stub_request(:post, "#{base_url}/empty")
        .to_return(status: 200, body: "", headers: {})

      result = client.post("/empty", {})
      expect(result).to eq({})
    end
  end

  # -----------------------------------------------------------------------
  # 4xx errors — fail fast, no retry
  # -----------------------------------------------------------------------
  describe "4xx fail-fast behavior" do
    it "raises AuthenticationError for 401" do
      stub_request(:post, "#{base_url}/auth")
        .to_return(status: 401, body: "Unauthorized")

      expect { client.post("/auth", {}) }.to raise_error(Backend::Errors::AuthenticationError)
    end

    it "raises AuthenticationError for 403" do
      stub_request(:post, "#{base_url}/forbidden")
        .to_return(status: 403, body: "Forbidden")

      expect { client.post("/forbidden", {}) }.to raise_error(Backend::Errors::AuthenticationError)
    end

    it "raises ValidationError for 400" do
      stub_request(:post, "#{base_url}/bad")
        .to_return(status: 400, body: "Bad Request")

      expect { client.post("/bad", {}) }.to raise_error(Backend::Errors::ValidationError)
    end

    it "does not retry on 401" do
      stub = stub_request(:post, "#{base_url}/noretry401")
        .to_return(status: 401, body: "")

      expect { client.post("/noretry401", {}) }.to raise_error(Backend::Errors::AuthenticationError)
      expect(stub).to have_been_requested.once
    end

    it "does not retry on 400" do
      stub = stub_request(:post, "#{base_url}/noretry400")
        .to_return(status: 400, body: "")

      expect { client.post("/noretry400", {}) }.to raise_error(Backend::Errors::ValidationError)
      expect(stub).to have_been_requested.once
    end
  end

  # -----------------------------------------------------------------------
  # 5xx retry behavior
  # -----------------------------------------------------------------------
  describe "5xx retry and RetryExhaustedError" do
    it "retries on 500 and raises RetryExhaustedError when all retries exhausted" do
      stub = stub_request(:post, "#{base_url}/server-error")
        .to_return(status: 500, body: "Internal Server Error")

      expect { client.post("/server-error", {}) }.to raise_error(
        Backend::Errors::RetryExhaustedError, /500 after 2 retries/
      )

      # 1 initial + 2 retries = 3 total requests
      expect(stub).to have_been_requested.times(3)
    end

    it "retries on 502 Bad Gateway" do
      stub = stub_request(:get, "#{base_url}/bad-gateway")
        .to_return(status: 502, body: "Bad Gateway")

      expect do
        client.get_authenticated("/bad-gateway", access_token: "tok", csrf_token: "csrf")
      end.to raise_error(Backend::Errors::RetryExhaustedError)

      expect(stub).to have_been_requested.times(3)
    end

    it "retries on 503 Service Unavailable" do
      stub = stub_request(:post, "#{base_url}/unavailable")
        .to_return(status: 503, body: "Service Unavailable")

      expect { client.post("/unavailable", {}) }.to raise_error(Backend::Errors::RetryExhaustedError)
      expect(stub).to have_been_requested.times(3)
    end

    it "retries on 504 Gateway Timeout" do
      stub = stub_request(:post, "#{base_url}/gateway-timeout")
        .to_return(status: 504, body: "Gateway Timeout")

      expect { client.post("/gateway-timeout", {}) }.to raise_error(Backend::Errors::RetryExhaustedError)
      expect(stub).to have_been_requested.times(3)
    end

    it "succeeds after transient 5xx followed by 200" do
      stub_request(:post, "#{base_url}/recoverable")
        .to_return(status: 503, body: "down")
        .then.to_return(status: 200, body: '{"recovered":true}', headers: { "Content-Type" => "application/json" })

      result = client.post("/recoverable", {})
      expect(result).to eq({ "recovered" => true })
    end
  end

  # -----------------------------------------------------------------------
  # Connection and timeout errors
  # -----------------------------------------------------------------------
  describe "connection failure handling" do
    it "raises ServiceUnavailableError on connection failure" do
      stub_request(:post, "#{base_url}/down")
        .to_raise(Faraday::ConnectionFailed.new("connection refused"))

      expect { client.post("/down", {}) }.to raise_error(Backend::Errors::ServiceUnavailableError)
    end

    it "raises ServiceUnavailableError on timeout" do
      stub_request(:post, "#{base_url}/slow")
        .to_raise(Faraday::TimeoutError.new("timed out"))

      expect { client.post("/slow", {}) }.to raise_error(Backend::Errors::ServiceUnavailableError)
    end
  end

  # -----------------------------------------------------------------------
  # Parse response edge cases
  # -----------------------------------------------------------------------
  describe "response parsing" do
    it "raises UnexpectedResponseError for non-JSON response body" do
      stub_request(:post, "#{base_url}/html")
        .to_return(status: 200, body: "<html>not json</html>")

      expect { client.post("/html", {}) }.to raise_error(Backend::Errors::UnexpectedResponseError, /JSON parse/)
    end

    it "raises UnexpectedResponseError for JSON array (non-object)" do
      stub_request(:post, "#{base_url}/array")
        .to_return(status: 200, body: '[1,2,3]')

      expect { client.post("/array", {}) }.to raise_error(Backend::Errors::UnexpectedResponseError, /JSON object/)
    end

    it "raises UnexpectedResponseError for unknown 4xx" do
      stub_request(:post, "#{base_url}/unknown4xx")
        .to_return(status: 422, body: "Unprocessable")

      expect { client.post("/unknown4xx", {}) }.to raise_error(Backend::Errors::UnexpectedResponseError, /422/)
    end
  end

  # -----------------------------------------------------------------------
  # Configuration constants
  # -----------------------------------------------------------------------
  describe "retry configuration" do
    it "defines bounded retry constants" do
      expect(described_class::MAX_RETRIES).to eq(2)
      expect(described_class::RETRY_INTERVAL).to eq(0.2)
      expect(described_class::BACKOFF_FACTOR).to eq(2)
      expect(described_class::RETRY_STATUSES).to eq([ 500, 502, 503, 504 ])
    end
  end

  # -----------------------------------------------------------------------
  # Error class existence
  # -----------------------------------------------------------------------
  describe "error classes" do
    it "defines RetryExhaustedError" do
      expect(Backend::Errors::RetryExhaustedError).to be < StandardError
    end

    it "defines CircuitOpenError" do
      expect(Backend::Errors::CircuitOpenError).to be < StandardError
    end
  end
end
