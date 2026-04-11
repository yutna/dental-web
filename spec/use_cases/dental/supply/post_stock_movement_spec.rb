require "rails_helper"

RSpec.describe Dental::Supply::PostStockMovement do
  it "posts stock movement" do
    result = described_class.call(
      item_type: "supply",
      item_code: "SUP-POST-001",
      direction: "in",
      quantity: 2,
      unit: "piece",
      source: "adjustment",
      reference_type: "adjustment",
      reference_id: "REF-POST-001"
    )

    expect(result[:movement]).to be_present
  end
end
