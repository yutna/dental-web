require "rails_helper"

RSpec.describe "Admin clinic services", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en")
  end

  it "allows admin users to access admin dashboard" do
    sign_in_as(username: "admin.test")

    get "/en/admin"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Admin dashboard")
  end

  it "denies non-admin users from admin dashboard" do
    sign_in_as(username: "clinician.test")

    get "/en/admin"

    expect(response).to redirect_to("/en")
  end

  it "creates clinic services via admin CRUD" do
    sign_in_as(username: "admin.test")

    post "/en/admin/clinic_services", params: {
      clinic_service: {
        code: "srv-501",
        name: "Emergency Extraction",
        default_duration_minutes: 45,
        active: "1"
      }
    }

    expect(response).to redirect_to("/en/admin/clinic_services")
    follow_redirect!
    expect(response.body).to include("SRV-501")
    expect(response.body).to include("Emergency Extraction")
  end
end
