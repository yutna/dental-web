require "rails_helper"

RSpec.describe "Admin dental supply categories", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en/workspace")
  end

  it "creates supply category for admin" do
    sign_in_as(username: "admin.test")

    post "/en/admin/dental/master_data/supply_categories", params: {
      dental_supply_category: {
        code: "sup-cat-001",
        name: "Consumables",
        active: "1"
      }
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/supply_categories")
    follow_redirect!
    expect(response.body).to include("SUP-CAT-001")
  end

  it "denies non-admin users" do
    sign_in_as(username: "clinician.test")

    get "/en/admin/dental/master_data/supply_categories"

    expect(response).to redirect_to("/en")
  end
end
