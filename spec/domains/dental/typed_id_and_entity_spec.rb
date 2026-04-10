require "rails_helper"

RSpec.describe Dental::TypedId do
  it "normalizes to uppercase" do
    id = described_class.new("visit-1")
    expect(id.to_s).to eq("VISIT-1")
  end

  it "rejects blank values" do
    expect { described_class.new(" ") }.to raise_error(ArgumentError, /cannot be blank/)
  end
end

RSpec.describe Dental::Ids::VisitId do
  it "requires VISIT- prefix" do
    expect { described_class.new("abc") }.to raise_error(ArgumentError, /must start with VISIT-/)
  end

  it "accepts valid prefixed ids" do
    expect(described_class.new("visit-100").to_s).to eq("VISIT-100")
  end
end

RSpec.describe Dental::Entity do
  it "coerces raw id values into typed IDs" do
    entity = described_class.new(id: "visit-200")
    expect(entity.id).to be_a(Dental::TypedId)
    expect(entity.id.to_s).to eq("VISIT-200")
  end
end
