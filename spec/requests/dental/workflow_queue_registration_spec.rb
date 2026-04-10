require "rails_helper"

RSpec.describe "Dental workflow queue registration", type: :request do
  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }
  end

  it "creates checked-in workflow from check-in and registers queue entry" do
    expect do
      post "/en/dental/visits/check_in", params: {
        visit_id: "VISIT-CHECKIN-1",
        patient_name: "Somchai Jaidee",
        mrn: "HN0008",
        vn: "VN-20260410-014",
        service: "Scaling"
      }
    end.to change(DentalQueueEntry, :count).by(1)
      .and change(DentalWorkflowTimelineEntry, :count).by(1)

    expect(response).to have_http_status(:created)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-CHECKIN-1",
      "current_stage" => "checked-in",
      "created" => true
    )

    queue_entry = DentalQueueEntry.find_by!(visit_id: "VISIT-CHECKIN-1")
    expect(queue_entry).to have_attributes(
      patient_name: "Somchai Jaidee",
      source: "walk_in",
      status: "scheduled"
    )
  end

  it "syncs appointments into registered queue entries and skips duplicates" do
    post "/en/dental/visits/sync_appointments"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "synced" => true,
      "created_registered_visits" => 4,
      "skipped_duplicates" => 0,
      "error_count" => 0
    )

    post "/en/dental/visits/sync_appointments"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "created_registered_visits" => 0,
      "skipped_duplicates" => 4,
      "error_count" => 0
    )
  end
end
