require "rails_helper"

RSpec.describe DentalInvoiceLineItem, type: :model do
  def create_invoice
    DentalInvoice.create!(
      invoice_id: "INV-2026-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-001",
      payment_status: "pending",
      total_amount: 0,
      copay_amount: 0
    )
  end

  def build_line_item(overrides = {})
    DentalInvoiceLineItem.new({
      dental_invoice: create_invoice,
      item_type: "procedure",
      item_code: "PROC-100",
      item_name: "Composite Filling",
      quantity: 1,
      unit_price: 1200,
      amount: 1200
    }.merge(overrides))
  end

  describe "validations" do
    it "is valid with complete attributes" do
      expect(build_line_item).to be_valid
    end

    it "requires item_type in allowed values" do
      item = build_line_item(item_type: "invalid")
      expect(item).not_to be_valid
    end

    it "requires item_code" do
      item = build_line_item(item_code: nil)
      expect(item).not_to be_valid
    end

    it "requires quantity > 0" do
      item = build_line_item(quantity: 0)
      expect(item).not_to be_valid
    end

    it "requires unit_price >= 0" do
      item = build_line_item(unit_price: -1)
      expect(item).not_to be_valid
    end

    it "requires amount >= 0" do
      item = build_line_item(amount: -1)
      expect(item).not_to be_valid
    end
  end
end
