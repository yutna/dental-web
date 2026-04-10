require "rails_helper"

RSpec.describe "Dental admin master-data gate", type: :system do
  before do
    driven_by :rack_test
  end

  it "supports admin master-data flow with audit visibility" do
    group = create(:dental_procedure_group, code: "PROC-GRP-GATE")

    visit "/en/session/new"
    fill_in "username", with: "admin.test"
    fill_in "password", with: "secret"
    click_button "Sign in"

    visit "/en/admin/dental"
    expect(page).to have_text("Dental governance dashboard")

    visit "/en/admin/dental/master_data/procedure_items/new"
    fill_in "dental_procedure_item_code", with: "PROC-GATE-1"
    fill_in "dental_procedure_item_name", with: "Gate Procedure"
    select group.code, from: "dental_procedure_item_procedure_group_id"
    fill_in "dental_procedure_item_price_opd", with: "1500"
    fill_in "dental_procedure_item_price_ipd", with: "1700"
    click_button "Create Dental procedure item"

    expect(page).to have_current_path("/en/admin/dental/master_data/procedure_items")
    expect(page).to have_text("PROC-GATE-1")

    visit "/en/admin/dental/audit_events"
    expect(page).to have_text("Dental admin audit events")
    expect(page).to have_text("No audit events found for current filters")
  end
end
