require "rails_helper"

RSpec.describe DentalInvoice, type: :model do
  def build_invoice(overrides = {})
    DentalInvoice.new({
      invoice_id: "INV-2026-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-001",
      payment_status: "pending",
      total_amount: 0,
      copay_amount: 0
    }.merge(overrides))
  end

  def create_invoice(overrides = {})
    build_invoice(overrides).tap(&:save!)
  end

  describe "validations" do
    it "is valid with complete attributes" do
      expect(build_invoice).to be_valid
    end

    it "requires invoice_id" do
      record = build_invoice(invoice_id: nil)
      expect(record).not_to be_valid
    end

    it "enforces unique invoice_id" do
      create_invoice(invoice_id: "INV-2026-DUPE")
      duplicate = build_invoice(invoice_id: "INV-2026-DUPE")
      expect(duplicate).not_to be_valid
    end

    it "requires visit_id" do
      record = build_invoice(visit_id: nil)
      expect(record).not_to be_valid
    end

    it "requires payment_status in allowed values" do
      record = build_invoice(payment_status: "invalid")
      expect(record).not_to be_valid
    end
  end

  describe "#mark_paid!" do
    it "transitions from pending to paid" do
      invoice = create_invoice
      invoice.mark_paid!
      expect(invoice.reload).to be_paid
      expect(invoice.paid_at).to be_present
    end

    it "rejects transition from already paid" do
      invoice = create_invoice(payment_status: "paid", paid_at: Time.current)
      expect { invoice.mark_paid! }.to raise_error(Dental::Errors::InvalidTransition)
    end
  end

  describe "#recalculate_totals!" do
    it "calculates total from line items" do
      invoice = create_invoice
      invoice.line_items.create!(
        item_type: "procedure", item_code: "PROC-1", item_name: "Filling",
        quantity: 1, unit_price: 1200, amount: 1200, copay_amount: 100
      )
      invoice.line_items.create!(
        item_type: "medication", item_code: "MED-1", item_name: "Lidocaine",
        quantity: 2, unit_price: 50, amount: 100, copay_amount: 0
      )
      invoice.recalculate_totals!

      expect(invoice.total_amount.to_f).to eq(1300.0)
      expect(invoice.copay_amount.to_f).to eq(100.0)
    end
  end

  describe "scopes" do
    before do
      create_invoice(payment_status: "pending")
      create_invoice(payment_status: "paid", paid_at: Time.current)
    end

    it ".pending returns pending invoices" do
      expect(DentalInvoice.pending.count).to eq(1)
    end

    it ".paid returns paid invoices" do
      expect(DentalInvoice.paid.count).to eq(1)
    end
  end
end
