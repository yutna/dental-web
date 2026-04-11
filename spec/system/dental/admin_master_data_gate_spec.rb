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

    page.driver.submit(:post, "/en/admin/dental/master_data/procedure_items", {
      dental_procedure_item: {
        code: "PROC-GATE-1",
        name: "Gate Procedure",
        procedure_group_id: group.id,
        price_opd: "1500",
        price_ipd: "1700",
        active: "1"
      }
    })

    visit "/en/admin/dental/master_data/procedure_items"
    expect(page).to have_text("PROC-GATE-1")

    visit "/en/admin/dental/audit_events"
    expect(page).to have_text("Dental admin audit events")
    expect(page).to have_text("procedure_item.created")
    expect(page).to have_text("DentalProcedureItem")
  end
end
