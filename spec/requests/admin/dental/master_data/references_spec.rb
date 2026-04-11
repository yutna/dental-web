require "rails_helper"

RSpec.describe "Admin dental references", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en/workspace")
  end

  it "creates reference for admin" do
    sign_in_as(username: "admin.test")

    post "/en/admin/dental/master_data/references", params: {
      dental_image_type_reference: {
        code: "xray-pan",
        name: "Panoramic X-Ray",
        active: "1"
      }
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/references")
    follow_redirect!
    expect(response.body).to include("XRAY-PAN")
  end

  it "denies non-admin users" do
    sign_in_as(username: "clinician.test")

    get "/en/admin/dental/master_data/references"

    expect(response).to redirect_to("/en")
  end
end
