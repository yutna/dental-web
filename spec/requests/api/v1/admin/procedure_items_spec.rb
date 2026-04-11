require "rails_helper"

RSpec.describe "API v1 admin procedure items", type: :request do
  let(:admin_headers) { api_auth_headers(username: "admin.test", roles: [ "admin" ]) }
  let(:user_headers) { api_auth_headers(username: "clinician.test", roles: [ "dentist" ]) }

  before do
    create(:dental_procedure_item)
  end

  it "returns procedure items for admin users" do
    get "/api/v1/admin/procedure_items", headers: admin_headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]).not_to be_empty
  end

  it "rejects non-admin users" do
    get "/api/v1/admin/procedure_items", headers: user_headers

    expect(response).to have_http_status(:forbidden)
  end
end
