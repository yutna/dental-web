require "rails_helper"

RSpec.describe "Admin dental coverages", type: :request do
  def sign_in_as(username:)
    post "/en/session", params: { username: username, password: "secret" }
    expect(response).to redirect_to("/en/workspace")
  end

  let!(:group) { create(:dental_procedure_group) }
  let!(:item) { create(:dental_procedure_item, procedure_group: group) }

  it "creates coverage for admin" do
    sign_in_as(username: "admin.test")

    post "/en/admin/dental/master_data/coverages", params: {
      dental_procedure_item_coverage: {
        procedure_item_id: item.id,
        eligibility_code: "UCS",
        effective_from: Date.current,
        price_opd: "80",
        price_ipd: "90",
        copay_amount: "",
        copay_percent: "",
        active: "1"
      }
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/coverages")
  end

  it "submits maker-checker request for sensitive updates" do
    sign_in_as(username: "admin.test")
    coverage = create(:dental_procedure_item_coverage, procedure_item: item, price_opd: 80, price_ipd: 90)

    patch "/en/admin/dental/master_data/coverages/#{coverage.id}", params: {
      dental_procedure_item_coverage: {
        procedure_item_id: item.id,
        eligibility_code: coverage.eligibility_code,
        effective_from: coverage.effective_from,
        effective_to: coverage.effective_to,
        price_opd: 120,
        price_ipd: coverage.price_ipd,
        copay_amount: coverage.copay_amount,
        copay_percent: coverage.copay_percent,
        active: coverage.active,
        lock_version: coverage.lock_version
      },
      require_approval: "true"
    }

    expect(response).to redirect_to("/en/admin/dental/master_data/coverages")
    request = DentalMasterDataChangeRequest.order(:id).last
    expect(request.change_type).to eq("price_update")
    expect(request.status).to eq("pending")
  end
end
