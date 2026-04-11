require "rails_helper"

RSpec.describe Dental::SupplyCosting::UsageStateMachine do
  describe ".allowed_transitions" do
    it "returns deducted and failed from pending_deduct" do
      expect(described_class.allowed_transitions("pending_deduct")).to contain_exactly("deducted", "failed")
    end

    it "returns empty from deducted (terminal)" do
      expect(described_class.allowed_transitions("deducted")).to be_empty
    end

    it "returns pending_deduct and deducted from failed" do
      expect(described_class.allowed_transitions("failed")).to contain_exactly("pending_deduct", "deducted")
    end

    it "returns empty for unknown status" do
      expect(described_class.allowed_transitions("bogus")).to be_empty
    end
  end

  describe ".valid_transition?" do
    it "allows pending_deduct -> deducted" do
      expect(described_class.valid_transition?(from_status: "pending_deduct", to_status: "deducted")).to be true
    end

    it "allows pending_deduct -> failed" do
      expect(described_class.valid_transition?(from_status: "pending_deduct", to_status: "failed")).to be true
    end

    it "allows failed -> pending_deduct (retry)" do
      expect(described_class.valid_transition?(from_status: "failed", to_status: "pending_deduct")).to be true
    end

    it "allows failed -> deducted (direct retry)" do
      expect(described_class.valid_transition?(from_status: "failed", to_status: "deducted")).to be true
    end

    it "disallows deducted -> anything" do
      expect(described_class.valid_transition?(from_status: "deducted", to_status: "pending_deduct")).to be false
      expect(described_class.valid_transition?(from_status: "deducted", to_status: "failed")).to be false
    end

    it "returns false for invalid status values" do
      expect(described_class.valid_transition?(from_status: "bogus", to_status: "deducted")).to be false
    end
  end
end
