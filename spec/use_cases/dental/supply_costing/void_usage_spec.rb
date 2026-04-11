require "rails_helper"

RSpec.describe Dental::SupplyCosting::VoidUsage, type: :use_case do
  def create_usage(overrides = {})
    DentalUsageRecord.create!({
      usage_id: "USAGE-#{SecureRandom.hex(4).upcase}",
      visit_id: "VISIT-001",
      clinical_post_id: "POST-001",
      item_type: "medication",
      item_code: "MED-100",
      item_name: "Lidocaine 2%",
      unit: "vial",
      requested_quantity: 5,
      deducted_quantity: 0,
      status: "pending_deduct",
      actor_id: "ACTOR-001"
    }.merge(overrides))
  end

  describe "#call" do
    it "voids a pending usage without compensating movement" do
      usage = create_usage
      result = described_class.call(usage_record: usage, reason: "Clinical post voided", actor_id: "ACTOR-002")

      expect(result[:usage_record].reload).to be_voided
      expect(result[:usage_record].void_reason).to eq("Clinical post voided")
      expect(result[:compensating_movement]).to be_nil
    end

    it "voids a deducted usage with compensating inbound movement" do
      usage = create_usage(
        status: "deducted",
        deducted_quantity: 5,
        deducted_at: Time.current,
        movement_ref: "MOV-OUT-ABCD1234"
      )
      result = described_class.call(usage_record: usage, reason: "Source post deleted", actor_id: "ACTOR-002")

      expect(result[:usage_record].reload).to be_voided
      movement = result[:compensating_movement]
      expect(movement).to be_a(DentalStockMovement)
      expect(movement.direction).to eq("in")
      expect(movement.quantity).to eq(5)
      expect(movement.reference_type).to eq("usage")
      expect(movement.reference_id).to eq(usage.usage_id)
      expect(movement.note).to include("Compensating return")
    end

    it "voids a failed usage without compensating movement" do
      usage = create_usage(status: "failed", deduct_error: "Insufficient stock", failed_at: Time.current)
      result = described_class.call(usage_record: usage, reason: "Cancelled", actor_id: "ACTOR-002")

      expect(result[:usage_record].reload).to be_voided
      expect(result[:compensating_movement]).to be_nil
    end

    it "raises when voiding an already voided record" do
      usage = create_usage(voided_at: Time.current, void_reason: "already voided")

      expect {
        described_class.call(usage_record: usage, reason: "Duplicate void", actor_id: "ACTOR-002")
      }.to raise_error(Dental::Errors::GuardViolation)
    end

    it "rolls back void if compensating movement fails" do
      usage = create_usage(
        status: "deducted",
        deducted_quantity: 5,
        deducted_at: Time.current,
        movement_ref: "MOV-OUT-ABCD1234"
      )

      allow(Dental::SupplyCosting::PostStockMovement).to receive(:call)
        .and_raise(ActiveRecord::RecordInvalid.new(DentalStockMovement.new))

      expect {
        described_class.call(usage_record: usage, reason: "Source post deleted", actor_id: "ACTOR-002")
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(usage.reload).not_to be_voided
    end
  end
end
