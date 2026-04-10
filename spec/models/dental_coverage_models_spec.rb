require "rails_helper"

RSpec.describe DentalProcedureItemCoverage, type: :model do
  it { is_expected.to validate_presence_of(:eligibility_code) }
  it { is_expected.to validate_presence_of(:effective_from) }
  it { is_expected.to validate_numericality_of(:price_opd).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:price_ipd).is_greater_than_or_equal_to(0) }

  it "rejects copay amount and percent together" do
    model = build(:dental_procedure_item_coverage, copay_amount: 10, copay_percent: 5)
    model.validate

    expect(model.errors[:base]).to include("copay_amount and copay_percent are mutually exclusive")
  end

  it "detects effective windows" do
    model = build(
      :dental_procedure_item_coverage,
      effective_from: Date.new(2026, 1, 1),
      effective_to: Date.new(2026, 3, 31)
    )

    expect(model.effective_on?(Date.new(2026, 2, 1))).to be(true)
    expect(model.effective_on?(Date.new(2026, 4, 1))).to be(false)
  end
end

RSpec.describe DentalSupplyItemCoverage, type: :model do
  it { is_expected.to validate_presence_of(:eligibility_code) }
  it { is_expected.to validate_presence_of(:effective_from) }
  it { is_expected.to validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }

  it "rejects effective_to before effective_from" do
    model = build(
      :dental_supply_item_coverage,
      effective_from: Date.new(2026, 3, 1),
      effective_to: Date.new(2026, 2, 1)
    )
    model.validate

    expect(model.errors[:effective_to]).to include("must be on or after effective_from")
  end
end
