require "rails_helper"

RSpec.describe Dental::Workflow::VisitStateMachine do
  describe ".allowed_transitions" do
    it "returns transitions for registered stage" do
      expect(described_class.allowed_transitions("registered")).to eq(%w[checked-in cancelled])
    end

    it "returns terminal transitions as empty list" do
      expect(described_class.allowed_transitions("completed")).to eq([])
      expect(described_class.allowed_transitions("referred-out")).to eq([])
      expect(described_class.allowed_transitions("cancelled")).to eq([])
    end
  end

  describe ".valid_transition?" do
    it "accepts allowed transition" do
      expect(described_class.valid_transition?(from_stage: "in-treatment", to_stage: "waiting-payment")).to be(true)
    end

    it "rejects disallowed transition" do
      expect(described_class.valid_transition?(from_stage: "registered", to_stage: "completed")).to be(false)
    end
  end
end
