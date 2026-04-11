require "rails_helper"

RSpec.describe Dental::SupplyCosting::BuildInvoice, type: :use_case do
  describe "#call" do
    let(:line_items) do
      [
        {
          item_type: "procedure",
          item_code: "PROC-100",
          item_name: "Composite Filling",
          quantity: 1,
          unit: "tooth",
          unit_price: 1200.0,
          price_source: "coverage",
          copay_amount: 100.0,
          copay_percent: nil
        },
        {
          item_type: "medication",
          item_code: "MED-100",
          item_name: "Lidocaine 2%",
          quantity: 2,
          unit: "vial",
          unit_price: 50.0,
          price_source: "master_fallback",
          copay_amount: nil,
          copay_percent: nil
        },
        {
          item_type: "supply",
          item_code: "SUP-200",
          item_name: "Gauze Pack",
          quantity: 3,
          unit: "pack",
          unit_price: 12.0,
          price_source: "master_fallback",
          copay_amount: nil,
          copay_percent: nil
        }
      ]
    end

    it "creates an invoice with line items and calculated totals" do
      result = described_class.call(
        visit_id: "VISIT-001",
        patient_name: "Preecha N.",
        eligibility_code: "UCS",
        line_items: line_items,
        actor_id: "STAFF-001"
      )

      invoice = result[:invoice]
      expect(invoice).to be_persisted
      expect(invoice.invoice_id).to start_with("INV-")
      expect(invoice.visit_id).to eq("VISIT-001")
      expect(invoice.patient_name).to eq("Preecha N.")
      expect(invoice.payment_status).to eq("pending")
      expect(invoice.line_items.count).to eq(3)

      # 1200 + 100 + 36 = 1336
      expect(invoice.total_amount.to_f).to eq(1336.0)
      expect(invoice.copay_amount.to_f).to eq(100.0)
    end

    it "calculates line item amount as quantity * unit_price" do
      result = described_class.call(
        visit_id: "VISIT-002",
        line_items: [ line_items.first ],
        actor_id: "STAFF-001"
      )

      item = result[:invoice].line_items.first
      expect(item.amount.to_f).to eq(1200.0)
      expect(item.price_source).to eq("coverage")
    end

    it "creates invoice with empty line items" do
      result = described_class.call(
        visit_id: "VISIT-003",
        line_items: [],
        actor_id: "STAFF-001"
      )

      expect(result[:invoice]).to be_persisted
      expect(result[:invoice].line_items).to be_empty
      expect(result[:invoice].total_amount.to_f).to eq(0)
    end

    it "generates unique invoice IDs" do
      r1 = described_class.call(visit_id: "V-1", line_items: [], actor_id: "S-1")
      r2 = described_class.call(visit_id: "V-2", line_items: [], actor_id: "S-1")

      expect(r1[:invoice].invoice_id).not_to eq(r2[:invoice].invoice_id)
    end
  end
end
