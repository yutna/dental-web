require "rails_helper"

RSpec.describe "API v1 billing sync", type: :request do
  let(:headers) { api_auth_headers(username: "admin.test", roles: [ "admin" ]) }

  before do
    DentalInvoice.create!(
      invoice_id: "INV-SYNC-001",
      visit_id: "VIS-SYNC-001",
      patient_name: "Sync Patient",
      payment_status: "pending",
      total_amount: 100,
      copay_amount: 0
    )
  end

  it "uses server-side shared secret for signature verification" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("PAYMENT_SYNC_SHARED_SECRET").and_return("server-secret")

    signature = OpenSSL::HMAC.hexdigest("SHA256", "server-secret", "INV-SYNC-001:paid")

    post "/api/v1/billing/sync", headers: headers, params: {
      invoice_id: "INV-SYNC-001",
      payment_status: "paid",
      signature: signature,
      shared_secret: "attacker-supplied-secret"
    }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "data" => include(
        "invoice_id" => "INV-SYNC-001",
        "payment_status" => "paid",
        "changed" => true
      )
    )
  end

  it "returns service unavailable when server secret is not configured" do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("PAYMENT_SYNC_SHARED_SECRET").and_return(nil)

    post "/api/v1/billing/sync", headers: headers, params: {
      invoice_id: "INV-SYNC-001",
      payment_status: "paid",
      signature: "invalid"
    }

    expect(response).to have_http_status(:service_unavailable)
    expect(response.parsed_body).to include(
      "error" => include("code" => "CONTRACT_MISMATCH")
    )
  end
end
