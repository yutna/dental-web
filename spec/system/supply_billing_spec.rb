require "rails_helper"

RSpec.describe "Supply billing", type: :system do
  before do
    driven_by :rack_test
    sign_in_as_admin
  end

  it "shows waiting payments board and requisitions pages" do
    visit "/en/dental/billing/waiting_payments"
    expect(page).to have_text("Waiting Payment")

    requisition = DentalRequisition.create!(requisition_id: "REQ-SYS-001", requester_id: "admin.test", status: "pending")
    requisition.line_items.create!(item_type: "supply", item_code: "SUP-1", item_name: "Glove", quantity: 1, unit: "piece")

    visit "/en/dental/supply/requisitions"
    expect(page).to have_text("REQ-SYS-001")

    visit "/en/dental/supply/requisitions/#{requisition.id}"
    expect(page).to have_text("Glove")
  end

  private

  def sign_in_as_admin
    visit "/en/session/new"
    fill_in "username", with: "admin.test"
    fill_in "password", with: "secret"
    click_button "Sign in"
  end
end
