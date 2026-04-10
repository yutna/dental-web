require "rails_helper"

RSpec.describe "Workspace", type: :request do
  it "renders the profile menu trigger for signed in users" do
    post "/en/session", params: { username: "clinician.test", password: "secret" }

    get "/en/workspace"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Profile menu")
    expect(response.body).to include("Appointment queue")
    expect(response.body).to include("Source")
  end

  it "renders queue-only payload for polling frame requests" do
    post "/en/session", params: { username: "clinician.test", password: "secret" }

    get "/en/workspace", params: { queue_only: "1", status: "in_progress", source: "walk_in" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No appointments found for current filters.")
    expect(response.body).to include("Profile menu")
  end
end
