require "rails_helper"

RSpec.describe "Dental foundation gate", type: :system do
  before do
    driven_by :rack_test
  end

  it "redirects unauthenticated users to localized sign-in" do
    visit "/en/dental"

    expect(page).to have_current_path("/en/session/new")
  end

  it "shows forbidden contract for users without dental workflow access" do
    visit "/en/session/new"
    fill_in "username", with: "clinician.test"
    fill_in "password", with: "secret"
    click_button "Sign in"

    page.driver.submit(:get, "/en/dental/visits/VISIT-1.json", {})

    expect(page.status_code).to eq(403)
    expect(page.body).to include("FORBIDDEN")
  end

  it "shows not found contract for missing visits" do
    visit "/en/session/new"
    fill_in "username", with: "admin.test"
    fill_in "password", with: "secret"
    click_button "Sign in"

    page.driver.submit(:get, "/en/dental/visits/VISIT-NOT-FOUND.json", {})

    expect(page.status_code).to eq(404)
    expect(page.body).to include("NOT_FOUND")
  end
end
