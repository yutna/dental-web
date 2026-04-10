require "rails_helper"

RSpec.describe "Admin procedure item bulk import", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en/workspace")
  end

  let!(:group) { create(:dental_procedure_group) }

  it "reports lock conflicts in preview" do
    sign_in_as(username: "admin.test")
    item = create(:dental_procedure_item, procedure_group: group)
    item.update!(name: "Concurrent update")

    post "/en/admin/dental/master_data/procedure_items/bulk_import_preview", params: {
      rows: [
        {
          procedure_group_id: group.id,
          code: item.code,
          name: "Preview update",
          price_opd: 99,
          price_ipd: 129,
          active: true,
          lock_version: 0
        }
      ]
    }

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["conflict_count"]).to eq(1)
    expect(body["applied_count"]).to eq(0)
  end

  it "applies rows with overwrite=true" do
    sign_in_as(username: "admin.test")
    item = create(:dental_procedure_item, procedure_group: group)
    item.update!(name: "Concurrent update")

    post "/en/admin/dental/master_data/procedure_items/bulk_import_apply", params: {
      overwrite: "true",
      rows: [
        {
          procedure_group_id: group.id,
          code: item.code,
          name: "Overwrite value",
          price_opd: 199,
          price_ipd: 299,
          active: true,
          lock_version: 0
        }
      ]
    }

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body["applied_count"]).to eq(1)
    expect(body["conflict_count"]).to eq(0)
    expect(item.reload.name).to eq("Overwrite value")
  end

  it "denies non-admin users" do
    sign_in_as(username: "clinician.test")

    post "/en/admin/dental/master_data/procedure_items/bulk_import_preview", params: { rows: [] }

    expect(response).to redirect_to("/en")
  end
end
