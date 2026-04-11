require "rails_helper"

RSpec.describe "Admin dental medication profiles", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en/workspace")
  end

  it "creates medication profile for admin" do
    sign_in_as(username: "admin.test")

    post "/en/admin/dental/master_data/medication_profiles", params: {
      dental_medication_profile: {
        code: "med-high-001",
        name: "High Alert Med",
        category: "high_alert",
        active: "1"
      }
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/medication_profiles")
    follow_redirect!
    expect(response.body).to include("MED-HIGH-001")
  end

  it "denies non-admin users" do
    sign_in_as(username: "clinician.test")

    get "/en/admin/dental/master_data/medication_profiles"

    expect(response).to redirect_to("/en")
  end
end
