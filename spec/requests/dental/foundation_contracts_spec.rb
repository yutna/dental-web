require "rails_helper"

RSpec.describe "Dental foundation contracts", type: :request do
  describe "forbidden contract" do
    it "returns FORBIDDEN for signed-in users without dental permissions" do
      post "/en/session", params: { username: "clinician.test", password: "secret" }

      get "/en/dental/visits/VISIT-1"

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body).to include(
        "error" => include(
          "code" => Dental::ErrorCode::FORBIDDEN,
          "message" => "Forbidden"
        )
      )
    end
  end

  describe "not found contract" do
    it "returns NOT_FOUND for missing visits" do
      post "/en/session", params: { username: "admin.test", password: "secret" }

      get "/en/dental/visits/VISIT-NOT-FOUND"

      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body).to include(
        "error" => include(
          "code" => Dental::ErrorCode::NOT_FOUND,
          "message" => "Not found",
          "details" => include("visit_id" => "VISIT-NOT-FOUND")
        )
      )
    end
  end

  describe "invalid transition contract" do
    it "returns INVALID_STAGE_TRANSITION for unsupported transition targets" do
      post "/en/session", params: { username: "admin.test", password: "secret" }

      patch "/en/dental/visits/VISIT-1/transition", params: { from_stage: "registered", to_stage: "queued" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body).to include(
        "error" => include(
          "code" => Dental::ErrorCode::INVALID_STAGE_TRANSITION,
          "message" => "Invalid stage transition",
          "details" => include(
            "visit_id" => "VISIT-1",
            "from_stage" => "registered",
            "to_stage" => "queued",
            "allowed_transitions" => contain_exactly("checked-in", "cancelled")
          )
        )
      )
    end
  end
end
