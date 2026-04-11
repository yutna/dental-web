require "rails_helper"

RSpec.describe "Admin dental supply items", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en/workspace")
  end

  let!(:category) { create(:dental_supply_category, code: "SUP-CAT-A") }

  it "creates supply item for admin" do
    sign_in_as(username: "admin.test")

    post "/en/admin/dental/master_data/supply_items", params: {
      dental_supply_item: {
        supply_category_id: category.id,
        code: "sup-item-001",
        name: "Gloves",
        unit: "box",
        unit_price: "99.50",
        active: "1"
      }
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/supply_items")
    follow_redirect!
    expect(response.body).to include("SUP-ITEM-001")
  end

  it "denies non-admin users" do
    sign_in_as(username: "clinician.test")

    get "/en/admin/dental/master_data/supply_items"

    expect(response).to redirect_to("/en")
  end
end
