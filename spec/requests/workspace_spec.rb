require "rails_helper"

RSpec.describe "Workspace", type: :request do
  it "renders the profile menu trigger for signed in users" do
    post "/en/session", params: { username: "clinician.test", password: "secret" }

    get "/en/workspace"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Profile menu")
    expect(response.body).to include("Appointment queue")
  end
end
