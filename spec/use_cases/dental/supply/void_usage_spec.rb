require "rails_helper"

RSpec.describe Dental::Supply::VoidUsage do
  it "voids deducted usage" do
    usage = DentalUsageRecord.create!(
      usage_id: "USG-VOID-001",
      visit_id: "VIS-VOID-001",
      item_type: "supply",
      item_code: "SUP-VOID-001",
      item_name: "Glove",
      requested_quantity: 1,
      unit: "piece",
      status: "pending_deduct"
    )

    Dental::SupplyCosting::PostStockMovement.call(
      item_type: "supply",
      item_code: "SUP-VOID-001",
      direction: "in",
      quantity: 5,
      unit: "piece",
      source: "adjustment",
      reference_type: "adjustment",
      reference_id: "STOCK-VOID-001"
    )

    Dental::SupplyCosting::DeductUsage.call(usage_record: usage, actor_id: "admin.test")

    result = described_class.call(usage_record: usage.reload, reason: "manual void", actor_id: "admin.test")
    expect(result[:usage_record].reload.voided_at).to be_present
    expect(result[:usage_record].void_reason).to eq("manual void")
  end
end
