require "rails_helper"

RSpec.describe "Workspace", type: :request do
  before do
    post "/en/session", params: { username: "clinician.test", password: "secret" }
  end

  it "renders the authenticated shell with workspace content for signed in users" do
    get "/en/workspace"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Sign out")
    expect(response.body).to include("Appointment Queue")
    expect(response.body).to include("Source")
  end

  it "renders stat summary cards" do
    get "/en/workspace"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Total visits")
    expect(response.body).to include("In progress")
    expect(response.body).to include("Ready")
    expect(response.body).to include("Waiting payment")
  end

  it "renders search and filter controls" do
    get "/en/workspace"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Search by patient")
    expect(response.body).to include("All statuses")
    expect(response.body).to include("All sources")
    expect(response.body).to include("Apply")
    expect(response.body).to include("Reset")
  end

  it "renders sync appointments button" do
    get "/en/workspace"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Sync Appointments")
  end

  it "renders queue-only payload for polling frame requests" do
    get "/en/workspace", params: { queue_only: "1", status: "in_progress", source: "walk_in" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No appointments found for current filters.")
    expect(response.body).to include("Sign out")
  end

  it "filters queue rows by status" do
    get "/en/workspace", params: { status: "completed" }

    expect(response).to have_http_status(:ok)
  end

  it "filters queue rows by source" do
    get "/en/workspace", params: { source: "walk_in" }

    expect(response).to have_http_status(:ok)
  end

  it "filters queue rows by search term" do
    get "/en/workspace", params: { search: "nonexistent" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No appointments found")
  end
end
