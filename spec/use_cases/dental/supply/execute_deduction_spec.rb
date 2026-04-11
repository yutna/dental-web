require "rails_helper"

RSpec.describe Dental::Supply::ExecuteDeduction do
  it "deducts usage via supply_costing flow" do
    usage = DentalUsageRecord.create!(
      usage_id: "USG-EXEC-001",
      visit_id: "VIS-EXEC-001",
      item_type: "supply",
      item_code: "SUP-EXEC-001",
      item_name: "Glove",
      requested_quantity: 1,
      unit: "piece",
      status: "pending_deduct"
    )

    Dental::SupplyCosting::PostStockMovement.call(
      item_type: "supply",
      item_code: "SUP-EXEC-001",
      direction: "in",
      quantity: 5,
      unit: "piece",
      source: "adjustment",
      reference_type: "adjustment",
      reference_id: "STOCK-EXEC-001"
    )

    result = described_class.call(usage_record: usage, actor_id: "admin.test")

    expect(result[:usage_record].reload.status).to eq("deducted")
  end
end
