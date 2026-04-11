require "rails_helper"

RSpec.describe Dental::Billing::SyncPayment do
  it "syncs paid status via billing wrapper" do
    invoice = Dental::SupplyCosting::BuildInvoice.call(
      visit_id: "VIS-BILL-WRAP-002",
      patient_name: "Wrap Sync",
      eligibility_code: "UCS",
      line_items: [
        {
          item_type: "procedure",
          item_code: "PROC-100",
          item_name: "Scaling",
          quantity: 1,
          unit: "case",
          unit_price: 100,
          price_source: "master_data"
        }
      ]
    )[:invoice]

    signature = OpenSSL::HMAC.hexdigest("SHA256", "secret", "#{invoice.invoice_id}:paid")

    result = described_class.call(
      invoice_id: invoice.invoice_id,
      payment_status: "paid",
      signature: signature,
      shared_secret: "secret"
    )

    expect(result[:invoice].reload.payment_status).to eq("paid")
  end
end
