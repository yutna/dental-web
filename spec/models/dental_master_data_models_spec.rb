require "rails_helper"

RSpec.describe DentalProcedureGroup, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }

  it "normalizes code to uppercase" do
    model = build(:dental_procedure_group, code: " proc-grp-99 ")
    model.validate

    expect(model.code).to eq("PROC-GRP-99")
  end
end

RSpec.describe DentalProcedureItem, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:price_opd).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:price_ipd).is_greater_than_or_equal_to(0) }

  it "belongs to procedure group" do
    group = create(:dental_procedure_group)
    item = create(:dental_procedure_item, procedure_group: group)

    expect(item.procedure_group).to eq(group)
  end
end

RSpec.describe DentalMedicationProfile, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:category) }
end

RSpec.describe DentalSupplyCategory, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
end

RSpec.describe DentalSupplyItem, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:unit) }

  it "belongs to supply category" do
    category = create(:dental_supply_category)
    item = create(:dental_supply_item, supply_category: category)

    expect(item.supply_category).to eq(category)
  end
end

RSpec.describe DentalToothReference, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:sort_order).only_integer }
end

RSpec.describe DentalToothSurfaceReference, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:sort_order).only_integer }
end

RSpec.describe DentalToothRootReference, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:sort_order).only_integer }
end

RSpec.describe DentalToothPieceReference, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:sort_order).only_integer }
end

RSpec.describe DentalImageTypeReference, type: :model do
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
end
