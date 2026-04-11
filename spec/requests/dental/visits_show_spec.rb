require "rails_helper"

RSpec.describe "Dental visits show (BFF)", type: :request do
  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }

    DentalQueueEntry.create!(
      visit_id: "VISIT-SHOW-BFF-1", patient_name: "Somchai Jaidee",
      mrn: "HN3001", service: "Scaling", starts_at: "09:00",
      status: "in_progress", source: "walk_in"
    )
    DentalWorkflowTimelineEntry.create!(
      visit_id: "VISIT-SHOW-BFF-1", from_stage: "registered",
      to_stage: "checked-in", event_type: "stage_transition",
      actor_id: "admin.test", metadata_json: "{}"
    )
  end

  it "renders the visit detail page with patient info" do
    get "/en/dental/visits/VISIT-SHOW-BFF-1"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Somchai Jaidee")
    expect(response.body).to include("HN3001")
  end

  it "renders timeline entries" do
    get "/en/dental/visits/VISIT-SHOW-BFF-1"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Timeline")
    expect(response.body).to include("checked-in")
  end

  it "renders allowed stage transitions" do
    get "/en/dental/visits/VISIT-SHOW-BFF-1"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("to_stage")
  end

  it "renders back-to-queue link" do
    get "/en/dental/visits/VISIT-SHOW-BFF-1"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Back to queue")
  end

  it "renders confirmation dialog attributes on transition forms" do
    get "/en/dental/visits/VISIT-SHOW-BFF-1"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("data-turbo-confirm")
  end

  it "returns JSON visit snapshot for format json" do
    get "/en/dental/visits/VISIT-SHOW-BFF-1", as: :json

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["visit_id"]).to eq("VISIT-SHOW-BFF-1")
    expect(body["current_stage"]).to eq("checked-in")
    expect(body["lock_version"]).to be_present
  end
end
