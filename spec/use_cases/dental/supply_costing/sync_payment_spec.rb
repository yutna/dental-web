require "rails_helper"

RSpec.describe Dental::SupplyCosting::SyncPayment, type: :use_case do
  let(:shared_secret) { "test-secret-key-2026" }

  def create_invoice(overrides = {})
    DentalInvoice.create!({
      invoice_id: "INV-2026-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-001",
      payment_status: "pending",
      total_amount: 2450,
      copay_amount: 0
    }.merge(overrides))
  end

  def sign(invoice_id, payment_status)
    OpenSSL::HMAC.hexdigest("SHA256", shared_secret, "#{invoice_id}:#{payment_status}")
  end

  describe "#call" do
    it "marks a pending invoice as paid with valid signature" do
      invoice = create_invoice
      sig = sign(invoice.invoice_id, "paid")

      result = described_class.call(
        invoice_id: invoice.invoice_id,
        payment_status: "paid",
        signature: sig,
        shared_secret: shared_secret
      )

      expect(result[:invoice].reload).to be_paid
      expect(result[:invoice].paid_at).to be_present
      expect(result[:changed]).to be true
    end

    it "returns changed: false when invoice is already paid (idempotent)" do
      invoice = create_invoice(payment_status: "paid", paid_at: Time.current)
      sig = sign(invoice.invoice_id, "paid")

      result = described_class.call(
        invoice_id: invoice.invoice_id,
        payment_status: "paid",
        signature: sig,
        shared_secret: shared_secret
      )

      expect(result[:changed]).to be false
    end

    it "returns changed: false when payment_status is not paid" do
      invoice = create_invoice
      sig = sign(invoice.invoice_id, "pending")

      result = described_class.call(
        invoice_id: invoice.invoice_id,
        payment_status: "pending",
        signature: sig,
        shared_secret: shared_secret
      )

      expect(result[:changed]).to be false
      expect(invoice.reload).to be_pending
    end

    it "rejects invalid signature" do
      invoice = create_invoice

      expect {
        described_class.call(
          invoice_id: invoice.invoice_id,
          payment_status: "paid",
          signature: "bad-signature",
          shared_secret: shared_secret
        )
      }.to raise_error(Dental::Errors::Forbidden) { |e|
        expect(e.details["message"]).to include("invalid payment callback signature")
      }
    end

    it "raises not found for unknown invoice" do
      sig = sign("INV-MISSING", "paid")

      expect {
        described_class.call(
          invoice_id: "INV-MISSING",
          payment_status: "paid",
          signature: sig,
          shared_secret: shared_secret
        )
      }.to raise_error(Dental::Errors::NotFound)
    end

    it "accepts custom paid_at timestamp" do
      invoice = create_invoice
      sig = sign(invoice.invoice_id, "paid")
      custom_time = Time.utc(2026, 4, 11, 10, 49, 0)

      result = described_class.call(
        invoice_id: invoice.invoice_id,
        payment_status: "paid",
        signature: sig,
        shared_secret: shared_secret,
        paid_at: custom_time
      )

      expect(result[:invoice].paid_at).to eq(custom_time)
    end
  end
end
