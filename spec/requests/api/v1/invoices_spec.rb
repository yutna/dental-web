require "rails_helper"

RSpec.describe "API v1 invoices", type: :request do
  let(:headers) { api_auth_headers(username: "admin.test", roles: [ "admin" ]) }

  before do
    invoice = DentalInvoice.create!(
      invoice_id: "INV-API-001",
      visit_id: "VIS-API-001",
      patient_name: "API Invoice",
      payment_status: "pending",
      total_amount: 100,
      copay_amount: 0
    )
    invoice.line_items.create!(item_type: "procedure", item_code: "PROC-100", item_name: "Scaling", quantity: 1, unit: "case", unit_price: 100, amount: 100)
  end

  it "lists invoices" do
    get "/api/v1/invoices", headers: headers

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]).not_to be_empty
  end
end
