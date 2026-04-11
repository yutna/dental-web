require "rails_helper"

RSpec.describe Dental::SupplyCosting::PostStockMovement do
  subject(:use_case) { described_class.new }

  let(:base_params) do
    {
      item_type: "medication",
      item_code: "MED-100",
      direction: "out",
      quantity: 5,
      unit: "vial",
      source: "pharmacy",
      reference_type: "usage",
      reference_id: "USAGE-001",
      actor_id: "ACTOR-001"
    }
  end

  describe "#call" do
    it "creates a stock movement and returns created: true" do
      result = use_case.call(**base_params)

      expect(result[:created]).to be true
      expect(result[:movement]).to be_a(DentalStockMovement)
      expect(result[:movement].movement_ref).to start_with("MOV-OUT-")
      expect(result[:movement].quantity).to eq(5)
    end

    it "generates MOV-IN prefix for inbound direction" do
      result = use_case.call(**base_params.merge(direction: "in"))

      expect(result[:movement].movement_ref).to start_with("MOV-IN-")
    end

    it "returns existing movement when idempotency key matches" do
      first = use_case.call(**base_params)
      second = use_case.call(**base_params)

      expect(second[:created]).to be false
      expect(second[:movement].id).to eq(first[:movement].id)
    end

    it "creates separate movements for different directions with same reference" do
      out_result = use_case.call(**base_params.merge(direction: "out"))
      in_result = use_case.call(**base_params.merge(direction: "in"))

      expect(out_result[:created]).to be true
      expect(in_result[:created]).to be true
      expect(out_result[:movement].id).not_to eq(in_result[:movement].id)
    end

    it "creates movement without idempotency when no reference provided" do
      params = base_params.merge(reference_type: nil, reference_id: nil)
      first = use_case.call(**params)
      second = use_case.call(**params)

      expect(first[:created]).to be true
      expect(second[:created]).to be true
      expect(first[:movement].id).not_to eq(second[:movement].id)
    end

    it "persists note when provided" do
      result = use_case.call(**base_params.merge(note: "Deduction for treatment"))

      expect(result[:movement].note).to eq("Deduction for treatment")
    end
  end
end
