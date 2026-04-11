require "rails_helper"

RSpec.describe "API v1 Visits", type: :request do
  let(:headers) { api_auth_headers }

  describe "GET /api/v1/visits/:id" do
    it "returns 404 when visit not found" do
      get "/api/v1/visits/NONEXISTENT", headers: headers

      expect(response).to have_http_status(:not_found)
    end

    context "with existing visit" do
      before do
        DentalQueueEntry.create!(
          visit_id: "VISIT-SHOW-1", patient_name: "Test Patient",
          mrn: "HN1234", service: "Scaling", starts_at: "09:00",
          status: "in_progress", source: "walk_in"
        )
        DentalWorkflowTimelineEntry.create!(
          visit_id: "VISIT-SHOW-1", from_stage: "registered",
          to_stage: "checked-in", event_type: "stage_transition",
          metadata_json: "{}"
        )
      end

      it "returns visit with timeline" do
        get "/api/v1/visits/VISIT-SHOW-1", headers: headers

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body["data"]["visit_id"]).to eq("VISIT-SHOW-1")
        expect(body["data"]["timeline"]).to be_an(Array)
        expect(body["data"]["timeline"].length).to eq(1)
        expect(body["data"]["timeline"][0]["to_stage"]).to eq("checked-in")
      end
    end
  end

  describe "PATCH /api/v1/visits/:id/transition" do
    before do
      DentalQueueEntry.create!(
        visit_id: "VISIT-TR-1", patient_name: "Transition Patient",
        mrn: "HN5555", service: "Filling", starts_at: "09:00",
        status: "in_progress", source: "walk_in"
      )
      DentalWorkflowTimelineEntry.create!(
        visit_id: "VISIT-TR-1", from_stage: "registered",
        to_stage: "checked-in", event_type: "stage_transition",
        metadata_json: "{}"
      )
    end

    it "transitions to valid next stage" do
      patch "/api/v1/visits/VISIT-TR-1/transition", headers: headers,
        params: { from_stage: "checked-in", to_stage: "screening" }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"]["from_stage"]).to eq("checked-in")
      expect(body["data"]["to_stage"]).to eq("screening")
    end

    it "rejects invalid transition" do
      patch "/api/v1/visits/VISIT-TR-1/transition", headers: headers,
        params: { from_stage: "checked-in", to_stage: "completed" }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      expect(body["error"]["code"]).to eq("INVALID_STAGE_TRANSITION")
    end
  end

  describe "POST /api/v1/visits/check_in" do
    it "creates a visit with check-in" do
      post "/api/v1/visits/check_in", headers: headers,
        params: { vn: "VN-TEST-001", patient_name: "New Patient", mrn: "HN7777" }

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["data"]["patient_name"]).to eq("New Patient")
    end
  end
end
