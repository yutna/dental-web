require "rails_helper"

RSpec.describe Dental::SupplyCosting::DeductUsage, type: :use_case do
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
    it "deducts stock and marks usage as deducted" do
      usage = create_usage
      result = described_class.call(usage_record: usage, actor_id: "ACTOR-002")

      expect(result[:usage_record].reload).to be_deducted
      expect(result[:usage_record].deducted_quantity).to eq(5)
      expect(result[:usage_record].movement_ref).to start_with("MOV-OUT-")
      expect(result[:movement]).to be_a(DentalStockMovement)
      expect(result[:created]).to be true
    end

    it "records movement with pharmacy source and usage reference" do
      usage = create_usage
      result = described_class.call(usage_record: usage, actor_id: "ACTOR-002")

      movement = result[:movement]
      expect(movement.direction).to eq("out")
      expect(movement.source).to eq("pharmacy")
      expect(movement.reference_type).to eq("usage")
      expect(movement.reference_id).to eq(usage.usage_id)
      expect(movement.quantity).to eq(5)
    end

    it "rejects non-pending usage records" do
      usage = create_usage(status: "deducted", deducted_quantity: 5, deducted_at: Time.current, movement_ref: "MOV-OUT-EXIST")

      expect {
        described_class.call(usage_record: usage)
      }.to raise_error(Dental::Errors::InvalidTransition)
    end

    context "when stock is insufficient" do
      before do
        allow(Dental::SupplyCosting::PostStockMovement).to receive(:call)
          .and_raise(Dental::Errors::InsufficientStock.new(
            details: { item_code: "MED-100", requested: 5, available: 2 }
          ))
      end

      it "marks usage as failed with error message" do
        usage = create_usage
        result = described_class.call(usage_record: usage, actor_id: "ACTOR-002")

        expect(result[:usage_record].reload).to be_failed
        expect(result[:usage_record].deduct_error).to eq("Insufficient stock")
        expect(result[:movement]).to be_nil
        expect(result[:error]).to be_a(Dental::Errors::InsufficientStock)
      end
    end

    it "is idempotent when movement already exists for the same usage" do
      usage = create_usage
      first_result = described_class.call(usage_record: usage, actor_id: "ACTOR-002")

      # Reset usage to pending to simulate a retry scenario with same movement
      usage2 = create_usage(usage_id: usage.usage_id.sub("USAGE", "USAGE2"))
      allow(Dental::SupplyCosting::PostStockMovement).to receive(:call)
        .and_return({ movement: first_result[:movement], created: false })

      result = described_class.call(usage_record: usage2, actor_id: "ACTOR-002")
      expect(result[:created]).to be false
      expect(result[:movement]).to eq(first_result[:movement])
    end
  end
end
