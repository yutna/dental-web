# spec/system/authentication_spec.rb
require "rails_helper"

# Run with: BACKEND_API_BASE_URL=https://your-backend-api bin/rspec spec/system/authentication_spec.rb
RSpec.describe "Authentication (E2E)", type: :system do
  before do
    driven_by :selenium, using: :headless_chrome
  end

  # Skip when backend API endpoint is not configured for system E2E runs.
  before do
    backend_url = ENV["BACKEND_API_BASE_URL"].to_s
    skip "System E2E requires BACKEND_API_BASE_URL" if backend_url.blank?
  end

  describe "sign-in flow" do
    it "signs in with valid dev credentials and reaches workspace page" do
      visit "/en/session/new"

      expect(page).to have_text("Sign in to continue")
      expect(page).to have_field("username")

      fill_in "username", with: "admin.s"
      fill_in "password", with: "123"
      click_button "Sign in"

      expect(page).to have_current_path("/en/workspace")
      expect(page).to have_text("Signed in successfully.")
    end

    it "shows error on invalid credentials" do
      visit "/en/session/new"

      fill_in "username", with: "wrong.user"
      fill_in "password", with: "badpassword"
      click_button "Sign in"

      expect(page).to have_current_path("/en/session")
      expect(page).to have_text("Invalid username or password.")
      expect(page).to have_field("username", with: "wrong.user")
    end

    it "signs out and returns to sign-in page" do
      # Sign in first
      visit "/en/session/new"
      fill_in "username", with: "admin.s"
      fill_in "password", with: "123"
      click_button "Sign in"
      expect(page).to have_current_path("/en/workspace")

      # Verify signed in by accessing workspace (which requires auth)
      visit "/en/workspace"
      expect(page).to have_http_status(:ok)

      # Sign out would require a sign-out link/button in the UI
      # For now, just delete session to simulate logout
      page.driver.browser.manage.delete_all_cookies
      visit "/en"

      expect(page).to have_current_path("/en/session/new")
    end

    it "redirects to login when accessing protected route unauthenticated" do
      visit "/en/workspace"

      expect(page).to have_current_path("/en/session/new")
    end
  end

  describe "Thai locale" do
    it "shows sign-in form in Thai" do
      visit "/th/session/new"

      expect(page).to have_text("ลงชื่อเข้าใช้งาน")
      expect(page).to have_field("username")
    end

    it "shows error in Thai on invalid credentials" do
      visit "/th/session/new"

      fill_in "username", with: "wrong"
      fill_in "password", with: "wrong"
      click_button "ลงชื่อเข้าใช้"

      expect(page).to have_text("ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง")
    end
  end
end
