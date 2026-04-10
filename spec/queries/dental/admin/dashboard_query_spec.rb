require "rails_helper"

RSpec.describe Dental::Admin::DashboardQuery do
  it "returns summary and resource totals" do
    create(:dental_procedure_group)
    create(:dental_procedure_item)
    create(:dental_medication_profile)
    create(:dental_supply_category)
    create(:dental_supply_item)

    result = described_class.call

    expect(result[:summary][:master_resources]).to be >= 5
    expect(result[:summary][:active_items]).to be >= 5
    expect(result[:summary][:pending_approvals]).to eq(0)
    expect(result[:summary][:sync_warnings]).to eq(0)
    expect(result[:totals][:procedure_groups]).to be >= 1
    expect(result[:totals][:procedure_items]).to be >= 1
  end
end
