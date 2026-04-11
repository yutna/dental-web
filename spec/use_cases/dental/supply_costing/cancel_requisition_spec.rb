require "rails_helper"

RSpec.describe Dental::SupplyCosting::CancelRequisition, type: :use_case do
  def create_requisition(overrides = {})
    DentalRequisition.create!({
      requisition_id: "REQ-#{SecureRandom.hex(4).upcase}",
      requester_id: "NURSE-001",
      status: "pending"
    }.merge(overrides))
  end

  describe "#call" do
    it "cancels a pending requisition with reason" do
      req = create_requisition
      result = described_class.call(requisition: req, reason: "No longer needed", actor_id: "HEAD-001")

      expect(result[:requisition].reload).to be_cancelled
      expect(result[:requisition].cancel_reason).to eq("No longer needed")
    end

    it "cancels an approved requisition" do
      req = create_requisition(status: "approved", approver_id: "HEAD-001", approved_at: Time.current)
      result = described_class.call(requisition: req, reason: "Duplicate", actor_id: "HEAD-001")

      expect(result[:requisition].reload).to be_cancelled
    end

    it "rejects cancel without reason" do
      req = create_requisition
      expect {
        described_class.call(requisition: req, reason: "", actor_id: "HEAD-001")
      }.to raise_error(Dental::Errors::GuardViolation)
    end

    it "rejects cancel of dispensed requisition" do
      req = create_requisition(
        status: "dispensed",
        approver_id: "HEAD-001",
        approved_at: Time.current,
        dispenser_id: "PHARM-001",
        dispense_number: "DISP-001",
        dispensed_at: Time.current
      )
      expect {
        described_class.call(requisition: req, reason: "Too late", actor_id: "HEAD-001")
      }.to raise_error(Dental::Errors::InvalidTransition)
    end
  end
end
