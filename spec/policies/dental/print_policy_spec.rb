require "rails_helper"

RSpec.describe Dental::PrintPolicy do
  let(:record) { Struct.new(:stage, :type).new(stage, "treatment_summary") }
  subject(:policy) { described_class.new(principal, record) }

  let(:stage) { "in-treatment" }
  let(:permissions) { [] }
  let(:principal) do
    Security::Principal.new(
      id: "user-1",
      email: "user@example.com",
      display_name: "User",
      roles: [ "dentist" ],
      permissions: permissions
    )
  end

  context "without print permission" do
    it "denies show" do
      expect(policy.show?).to be false
    end
  end

  context "with print permission" do
    let(:permissions) { [ "dental:print:read" ] }

    it "allows show for printable stage" do
      expect(policy.show?).to be true
    end

    context "when stage is registered" do
      let(:stage) { "registered" }

      it "denies show" do
        expect(policy.show?).to be false
      end
    end

    context "when stage is cancelled" do
      let(:stage) { "cancelled" }

      it "denies show" do
        expect(policy.show?).to be false
      end
    end

    context "when stage is completed" do
      let(:stage) { "completed" }

      it "allows show" do
        expect(policy.show?).to be true
      end
    end
  end

  context "with symbol-like record (matrix compatibility)" do
    let(:permissions) { [ "dental:print:read" ] }
    let(:record) { :print }

    it "allows show when no stage context is present" do
      expect(policy.show?).to be true
    end
  end
end
