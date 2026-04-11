require "rails_helper"

RSpec.describe "API v1 Base Auth", type: :request do
  describe "authentication" do
    it "returns 401 without authorization header" do
      get "/api/v1/queues"

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to include(
        "error" => include("code" => "UNAUTHORIZED")
      )
    end

    it "returns 401 with invalid bearer token" do
      get "/api/v1/queues", headers: { "Authorization" => "Bearer invalid-token" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 with empty bearer" do
      get "/api/v1/queues", headers: { "Authorization" => "Bearer " }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 401 with non-bearer auth" do
      get "/api/v1/queues", headers: { "Authorization" => "Basic dGVzdDp0ZXN0" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "accepts valid bearer token and returns success" do
      get "/api/v1/queues", headers: api_auth_headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include("data")
    end
  end

  describe "error envelope" do
    it "returns standard error shape for all errors" do
      get "/api/v1/queues"

      body = response.parsed_body
      expect(body["error"]).to include("code", "message")
    end
  end

  describe "pagination" do
    before do
      3.times do |i|
        DentalQueueEntry.create!(
          visit_id: "VISIT-PAGE-#{i}",
          patient_name: "Patient #{i}",
          mrn: "HN000#{i}",
          service: "Filling",
          starts_at: "09:0#{i}",
          status: "scheduled",
          source: "walk_in"
        )
      end
    end

    it "returns paginated results with meta" do
      get "/api/v1/queues", headers: api_auth_headers, params: { per_page: 2, page: 1 }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"].length).to eq(2)
      expect(body["meta"]).to include(
        "page" => 1,
        "per_page" => 2,
        "total" => 3,
        "total_pages" => 2
      )
    end

    it "caps per_page at 100" do
      get "/api/v1/queues", headers: api_auth_headers, params: { per_page: 500 }

      body = response.parsed_body
      expect(body["meta"]["per_page"]).to eq(100)
    end
  end
end
