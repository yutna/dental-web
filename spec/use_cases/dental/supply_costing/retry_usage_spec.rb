require "rails_helper"

RSpec.describe Dental::SupplyCosting::RetryUsage, type: :use_case do
  def create_usage(overrides = {})
    DentalUsageRecord.create!({
      usage_id: "USAGE-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-001",
      clinical_post_id: "POST-001",
      item_type: "supply",
      item_code: "SUP-200",
      item_name: "Gauze Pack",
      unit: "pack",
      requested_quantity: 3,
      deducted_quantity: 0,
      status: "failed",
      deduct_error: "Insufficient stock",
      failed_at: Time.current,
      actor_id: "ACTOR-001"
    }.merge(overrides))
  end

  describe "#call" do
    it "resets failed usage to pending and re-runs deduction" do
      usage = create_usage
      result = described_class.call(usage_record: usage, actor_id: "ACTOR-002")

      expect(result[:usage_record].reload).to be_deducted
      expect(result[:usage_record].deducted_quantity).to eq(3)
      expect(result[:movement]).to be_a(DentalStockMovement)
      expect(result[:created]).to be true
    end

    it "marks failed again if deduction still fails" do
      usage = create_usage

      allow(Dental::SupplyCosting::PostStockMovement).to receive(:call)
        .and_raise(Dental::Errors::InsufficientStock.new(
          details: { item_code: "SUP-200", requested: 3, available: 0 }
        ))

      result = described_class.call(usage_record: usage, actor_id: "ACTOR-002")

      expect(result[:usage_record].reload).to be_failed
      expect(result[:error]).to be_a(Dental::Errors::InsufficientStock)
    end

    it "rejects non-failed usage records" do
      usage = create_usage(status: "pending_deduct", deduct_error: nil, failed_at: nil)

      expect {
        described_class.call(usage_record: usage)
      }.to raise_error(Dental::Errors::InvalidTransition)
    end
  end
end
