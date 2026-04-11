require "rails_helper"

RSpec.describe "API v1 Queues", type: :request do
  let(:headers) { api_auth_headers }

  describe "GET /api/v1/queues" do
    it "returns empty collection when no entries" do
      get "/api/v1/queues", headers: headers

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["data"]).to eq([])
      expect(body["meta"]["total"]).to eq(0)
    end

    context "with queue entries" do
      before do
        DentalQueueEntry.create!(
          visit_id: "VISIT-Q1", patient_name: "Somchai J.",
          mrn: "HN0008", service: "Scaling", starts_at: "09:00",
          status: "in_progress", source: "walk_in", dentist: "Dr. Mook"
        )
        DentalQueueEntry.create!(
          visit_id: "VISIT-Q2", patient_name: "Mali C.",
          mrn: "HN0014", service: "Filling", starts_at: "09:10",
          status: "scheduled", source: "appointment_sync", dentist: "Dr. Narin"
        )
      end

      it "returns all entries" do
        get "/api/v1/queues", headers: headers

        body = response.parsed_body
        expect(body["data"].length).to eq(2)
        expect(body["meta"]["total"]).to eq(2)
      end

      it "filters by status" do
        get "/api/v1/queues", headers: headers, params: { status: "in_progress" }

        body = response.parsed_body
        expect(body["data"].length).to eq(1)
        expect(body["data"][0]["patient_name"]).to eq("Somchai J.")
      end

      it "searches by patient name" do
        get "/api/v1/queues", headers: headers, params: { search: "Mali" }

        body = response.parsed_body
        expect(body["data"].length).to eq(1)
        expect(body["data"][0]["mrn"]).to eq("HN0014")
      end

      it "searches by MRN" do
        get "/api/v1/queues", headers: headers, params: { search: "HN0008" }

        body = response.parsed_body
        expect(body["data"].length).to eq(1)
        expect(body["data"][0]["patient_name"]).to eq("Somchai J.")
      end

      it "returns correct serialized shape" do
        get "/api/v1/queues", headers: headers

        entry = response.parsed_body["data"][0]
        expect(entry).to include(
          "visit_id", "patient_name", "mrn", "service",
          "dentist", "status", "source", "starts_at",
          "created_at", "updated_at"
        )
      end
    end
  end

  describe "POST /api/v1/queues" do
    let(:valid_params) do
      {
        visit_id: "VISIT-NEW-1",
        patient_name: "New Patient",
        mrn: "HN9999",
        service: "Extraction",
        starts_at: "10:00",
        source: "walk_in"
      }
    end

    it "creates a queue entry" do
      post "/api/v1/queues", headers: headers, params: valid_params

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["data"]["visit_id"]).to eq("VISIT-NEW-1")
      expect(body["data"]["patient_name"]).to eq("New Patient")
    end
  end
end
