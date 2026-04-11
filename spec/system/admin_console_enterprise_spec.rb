require "rails_helper"

RSpec.describe "Admin console enterprise", type: :system do
  before do
    driven_by :rack_test
    sign_in_as_admin
  end

  it "creates master data records across medication, supply, and references" do
    visit "/en/admin/dental/master_data/medication_profiles/new"
    fill_in "dental_medication_profile_code", with: "med-enterprise-001"
    fill_in "dental_medication_profile_name", with: "Enterprise Med"
    fill_in "dental_medication_profile_category", with: "general"
    click_button "Create Dental medication profile"

    expect(page).to have_current_path("/en/admin/dental/master_data/medication_profiles")
    expect(page).to have_text("MED-ENTERPRISE-001")

    visit "/en/admin/dental/master_data/supply_categories/new"
    fill_in "dental_supply_category_code", with: "sup-enterprise-001"
    fill_in "dental_supply_category_name", with: "Enterprise Category"
    click_button "Create Dental supply category"

    expect(page).to have_current_path("/en/admin/dental/master_data/supply_categories")
    expect(page).to have_text("SUP-ENTERPRISE-001")

    category = DentalSupplyCategory.find_by!(code: "SUP-ENTERPRISE-001")

    visit "/en/admin/dental/master_data/supply_items/new"
    select category.code, from: "dental_supply_item_supply_category_id"
    fill_in "dental_supply_item_code", with: "sup-item-enterprise-001"
    fill_in "dental_supply_item_name", with: "Surgical Gloves"
    fill_in "dental_supply_item_unit", with: "box"
    fill_in "dental_supply_item_unit_price", with: "110"
    click_button "Create Dental supply item"

    expect(page).to have_current_path("/en/admin/dental/master_data/supply_items")
    expect(page).to have_text("SUP-ITEM-ENTERPRISE-001")

    visit "/en/admin/dental/master_data/references/new"
    fill_in "dental_image_type_reference_code", with: "xray-enterprise-001"
    fill_in "dental_image_type_reference_name", with: "Enterprise X-Ray"
    click_button "Create Dental image type reference"

    expect(page).to have_current_path("/en/admin/dental/master_data/references")
    expect(page).to have_text("XRAY-ENTERPRISE-001")
  end

  private

  def sign_in_as_admin
    visit "/en/session/new"
    fill_in "username", with: "admin.test"
    fill_in "password", with: "secret"
    click_button "Sign in"
  end
end
