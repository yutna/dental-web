require "rails_helper"

RSpec.describe Dental::RequisitionPolicy do
  subject(:policy) { described_class.new(principal, :requisition) }

  let(:permissions) { [] }
  let(:principal) do
    Security::Principal.new(
      id: "user-1",
      email: "user@example.com",
      display_name: "User",
      roles: [ "dental_staff" ],
      permissions: permissions
    )
  end

  context "with no permissions" do
    it "denies all actions" do
      expect(policy.index?).to be false
      expect(policy.show?).to be false
      expect(policy.create?).to be false
      expect(policy.approve?).to be false
      expect(policy.dispense?).to be false
      expect(policy.receive?).to be false
      expect(policy.cancel?).to be false
    end
  end

  context "with read permission" do
    let(:permissions) { [ "dental:requisition:read" ] }

    it "allows index and show" do
      expect(policy.index?).to be true
      expect(policy.show?).to be true
    end

    it "denies write actions" do
      expect(policy.create?).to be false
      expect(policy.approve?).to be false
    end
  end

  context "with write permission" do
    let(:permissions) { [ "dental:requisition:write" ] }

    it "allows create and cancel" do
      expect(policy.create?).to be true
      expect(policy.cancel?).to be true
    end

    it "denies approve and dispense" do
      expect(policy.approve?).to be false
      expect(policy.dispense?).to be false
    end
  end

  context "with approve permission" do
    let(:permissions) { [ "dental:requisition:approve" ] }

    it "allows approve" do
      expect(policy.approve?).to be true
    end

    it "denies dispense" do
      expect(policy.dispense?).to be false
    end
  end

  context "with dispense permission" do
    let(:permissions) { [ "dental:requisition:dispense" ] }

    it "allows dispense" do
      expect(policy.dispense?).to be true
    end
  end

  context "with receive permission" do
    let(:permissions) { [ "dental:requisition:receive" ] }

    it "allows receive" do
      expect(policy.receive?).to be true
    end
  end
end
