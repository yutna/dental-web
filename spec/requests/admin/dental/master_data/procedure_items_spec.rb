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

  it "deactivates referenced items instead of hard delete" do
    sign_in_as(username: "admin.test")
    item = create(:dental_procedure_item, procedure_group: group, active: true)
    create(:dental_procedure_item_coverage, procedure_item: item)

    delete "/en/admin/dental/master_data/procedure_items/#{item.id}"

    expect(response).to redirect_to("/en/admin/dental/master_data/procedure_items")
    expect(item.reload.active).to be(false)
    expect(DentalProcedureItem.exists?(item.id)).to be(true)
  end

  it "deactivates non-referenced active items" do
    sign_in_as(username: "admin.test")
    item = create(:dental_procedure_item, procedure_group: group, active: true)

    delete "/en/admin/dental/master_data/procedure_items/#{item.id}"

    expect(response).to redirect_to("/en/admin/dental/master_data/procedure_items")
    expect(item.reload.active).to be(false)
  end

  it "submits a pending approval request for sensitive price changes" do
    sign_in_as(username: "admin.test")
    item = create(:dental_procedure_item, procedure_group: group, price_opd: 100, price_ipd: 200)

    patch "/en/admin/dental/master_data/procedure_items/#{item.id}", params: {
      dental_procedure_item: {
        procedure_group_id: group.id,
        code: item.code,
        name: item.name,
        price_opd: 999,
        price_ipd: 200,
        active: item.active,
        lock_version: item.lock_version
      },
      require_approval: "true"
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/procedure_items")
    expect(item.reload.price_opd).to eq(100)

    request = DentalMasterDataChangeRequest.order(:id).last
    expect(request.status).to eq("pending")
    expect(request.change_type).to eq("price_update")
  end

  it "blocks self-approval and allows approval by another admin" do
    sign_in_as(username: "admin.test")
    item = create(:dental_procedure_item, procedure_group: group, price_opd: 100, price_ipd: 200)

    patch "/en/admin/dental/master_data/procedure_items/#{item.id}", params: {
      dental_procedure_item: {
        procedure_group_id: group.id,
        code: item.code,
        name: item.name,
        price_opd: 777,
        price_ipd: 200,
        active: item.active,
        lock_version: item.lock_version
      },
      require_approval: "true"
    }

    request = DentalMasterDataChangeRequest.order(:id).last

    post "/en/admin/dental/master_data/procedure_items/#{item.id}/approve_price_change", params: {
      change_request_id: request.id
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/procedure_items")
    expect(item.reload.price_opd).to eq(100)
    expect(request.reload.status).to eq("pending")

    sign_in_as(username: "admin@example.com")

    post "/en/admin/dental/master_data/procedure_items/#{item.id}/approve_price_change", params: {
      change_request_id: request.id
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/procedure_items")
    expect(item.reload.price_opd).to eq(777)
    expect(request.reload.status).to eq("approved")
  end
end
