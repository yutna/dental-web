require "rails_helper"

RSpec.describe Dental::MasterData::RuntimePricingResolver do
  describe "procedure pricing" do
    let(:item) { create(:dental_procedure_item, price_opd: 120, price_ipd: 150) }

    it "uses active coverage price when effective" do
      create(
        :dental_procedure_item_coverage,
        procedure_item: item,
        eligibility_code: "UCS",
        effective_from: Date.new(2026, 1, 1),
        effective_to: Date.new(2026, 12, 31),
        price_opd: 80,
        price_ipd: 95
      )

      result = described_class.call(
        item: item,
        eligibility_code: "UCS",
        price_context: :opd,
        at: Date.new(2026, 4, 1)
      )

      expect(result).to be_ok
      expect(result.payload).to include("source" => "coverage", "price" => 80.0)
    end

    it "falls back to master price when coverage is expired" do
      create(
        :dental_procedure_item_coverage,
        procedure_item: item,
        eligibility_code: "UCS",
        effective_from: Date.new(2025, 1, 1),
        effective_to: Date.new(2025, 12, 31),
        price_opd: 70
      )

      result = described_class.call(
        item: item,
        eligibility_code: "UCS",
        price_context: :opd,
        at: Date.new(2026, 4, 1)
      )

      expect(result).to be_ok
      expect(result.payload).to include("source" => "master_fallback", "price" => 120.0)
    end
  end

  describe "supply pricing" do
    let(:item) { create(:dental_supply_item, unit_price: 20) }

    it "uses supply coverage unit price when effective" do
      create(
        :dental_supply_item_coverage,
        supply_item: item,
        eligibility_code: "UCS",
        effective_from: Date.new(2026, 1, 1),
        effective_to: Date.new(2026, 12, 31),
        unit_price: 11.5
      )

      result = described_class.call(
        item: item,
        eligibility_code: "UCS",
        at: Date.new(2026, 7, 1)
      )

      expect(result.payload).to include("source" => "coverage", "price" => 11.5)
    end

    it "falls back to master supply price when no active coverage exists" do
      result = described_class.call(
        item: item,
        eligibility_code: "UCS",
        at: Date.new(2026, 7, 1)
      )

      expect(result.payload).to include("source" => "master_fallback", "price" => 20.0)
    end
  end
end
