require "rails_helper"

RSpec.describe Dental::Supply::UsageStateMachine do
  it "delegates allowed transitions to supply_costing contract" do
    expect(described_class.allowed_transitions("pending_deduct")).to include("deducted", "failed")
  end
end
