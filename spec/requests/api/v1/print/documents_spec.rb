require "rails_helper"

RSpec.describe "API v1 print documents", type: :request do
  let(:visit_id) { "VISIT-API-PRINT-001" }

  before do
    DentalQueueEntry.create!(
      visit_id: visit_id,
      patient_name: "Api Patient",
      mrn: "HN-API-001",
      service: "General Consultation",
      starts_at: "10:00",
      status: "in_progress",
      source: "walk_in",
      metadata_json: "{}"
    )

    DentalWorkflowTimelineEntry.create!(
      visit_id: visit_id,
      from_stage: "checked-in",
      to_stage: "in-treatment",
      event_type: "stage_transition",
      actor_id: "admin.test",
      metadata_json: "{}"
    )
  end

  it "returns treatment summary payload" do
    get "/api/v1/print/documents/#{visit_id}/treatment_summary", headers: api_auth_headers

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json.dig("data", "visit_id")).to eq(visit_id)
    expect(json.dig("data", "type")).to eq("treatment_summary")
    expect(json.dig("data", "payload", "patient_name")).to eq("Api Patient")
  end

  it "returns dental chart payload" do
    get "/api/v1/print/documents/#{visit_id}/dental_chart", headers: api_auth_headers

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json.dig("data", "type")).to eq("dental_chart")
  end

  it "returns not found for unknown print type" do
    get "/api/v1/print/documents/#{visit_id}/unknown", headers: api_auth_headers

    expect(response).to have_http_status(:not_found)
  end

  it "returns unauthorized without bearer token" do
    get "/api/v1/print/documents/#{visit_id}/treatment_summary"

    expect(response).to have_http_status(:unauthorized)
  end

  it "returns forbidden for blocked print stage" do
    DentalWorkflowTimelineEntry.where(visit_id: visit_id).delete_all

    get "/api/v1/print/documents/#{visit_id}/treatment_summary", headers: api_auth_headers

    expect(response).to have_http_status(:forbidden)
  end
end
