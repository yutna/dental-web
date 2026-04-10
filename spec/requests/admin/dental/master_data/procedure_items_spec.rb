require "rails_helper"

RSpec.describe "Admin dental procedure items", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en/workspace")
  end

  let!(:group) { create(:dental_procedure_group, code: "PROC-GRP-A") }

  it "allows admin users to create procedure items" do
    sign_in_as(username: "admin.test")

    post "/en/admin/dental/master_data/procedure_items", params: {
      dental_procedure_item: {
        procedure_group_id: group.id,
        code: "proc-900",
        name: "Composite Filling",
        price_opd: "1200",
        price_ipd: "1400",
        active: "1"
      }
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/procedure_items")
    follow_redirect!
    expect(response.body).to include("PROC-900")
  end

  it "returns conflict when lock_version is stale" do
    sign_in_as(username: "admin.test")
    item = create(:dental_procedure_item, procedure_group: group)

    item.update!(name: "Updated by other request")

    patch "/en/admin/dental/master_data/procedure_items/#{item.id}", params: {
      dental_procedure_item: {
        procedure_group_id: group.id,
        code: item.code,
        name: "Attempt stale update",
        price_opd: item.price_opd,
        price_ipd: item.price_ipd,
        active: item.active,
        lock_version: 0
      }
    }

    expect(response).to have_http_status(:conflict)
    expect(response.body).to include("updated by someone else")
  end

  it "denies non-admin users" do
    sign_in_as(username: "clinician.test")

    get "/en/admin/dental/master_data/procedure_items"

    expect(response).to redirect_to("/en")
  end
end
