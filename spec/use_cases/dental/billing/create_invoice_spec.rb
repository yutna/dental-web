require "rails_helper"

RSpec.describe Dental::Billing::CreateInvoice do
  it "creates invoice via billing wrapper" do
    result = described_class.call(
      visit_id: "VIS-BILL-WRAP-001",
      patient_name: "Wrap Bill",
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
    )

    expect(result[:invoice].invoice_id).to start_with("INV-")
  end
end
