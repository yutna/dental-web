require "rails_helper"

RSpec.describe Dental::SupplyCosting::WaitingPaymentQuery do
  def create_invoice(overrides = {})
    DentalInvoice.create!({
      invoice_id: "INV-2026-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-001",
      payment_status: "pending",
      total_amount: 100,
      copay_amount: 0
    }.merge(overrides))
  end

  describe "#call" do
    it "returns pending invoices by default" do
      pending_inv = create_invoice(payment_status: "pending")
      create_invoice(payment_status: "paid", paid_at: Time.current)

      result = described_class.call
      expect(result).to include(pending_inv)
      expect(result.size).to eq(1)
    end

    it "filters by specific status when provided" do
      create_invoice(payment_status: "pending")
      paid_inv = create_invoice(payment_status: "paid", paid_at: Time.current)

      result = described_class.call(status: "paid")
      expect(result).to include(paid_inv)
      expect(result.size).to eq(1)
    end

    it "orders by created_at descending" do
      older = create_invoice(created_at: 2.hours.ago)
      newer = create_invoice(created_at: 1.hour.ago)

      result = described_class.call
      expect(result.first).to eq(newer)
      expect(result.last).to eq(older)
    end
  end
end
