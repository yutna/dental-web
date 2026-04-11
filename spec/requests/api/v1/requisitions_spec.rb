require "rails_helper"

RSpec.describe "API v1 requisitions", type: :request do
  let(:headers) { api_auth_headers(username: "admin.test", roles: [ "admin" ]) }

  before do
    requisition = DentalRequisition.create!(requisition_id: "REQ-API-001", requester_id: "admin.test", status: "pending")
    requisition.line_items.create!(item_type: "supply", item_code: "SUP-100", item_name: "Glove", quantity: 1, unit: "piece")
  end

  it "lists requisitions" do
    get "/api/v1/requisitions", headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]).not_to be_empty
  end
end
