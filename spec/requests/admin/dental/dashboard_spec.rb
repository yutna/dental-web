require "rails_helper"

RSpec.describe "Admin dental dashboard", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en/workspace")
  end

  it "allows admin users to view dashboard and KPI labels" do
    sign_in_as(username: "admin.test")

    get "/en/admin/dental"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Dental governance dashboard")
    expect(response.body).to include("Master resources")
  end

  it "denies non-admin users from dashboard" do
    sign_in_as(username: "clinician.test")

    get "/en/admin/dental"

    expect(response).to redirect_to("/en")
  end
end
