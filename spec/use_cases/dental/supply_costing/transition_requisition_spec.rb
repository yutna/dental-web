require "rails_helper"

RSpec.describe Dental::SupplyCosting::TransitionRequisition, type: :use_case do
  def create_requisition(overrides = {})
    DentalRequisition.create!({
      requisition_id: "REQ-#{SecureRandom.hex(4).upcase}",
      requester_id: "NURSE-001",
      status: "pending"
    }.merge(overrides))
  end

  describe "#call" do
    context "approve" do
      it "approves a pending requisition" do
        req = create_requisition
        result = described_class.call(requisition: req, action: "approve", actor_id: "HEAD-001")
        expect(result[:requisition].reload).to be_approved
      end

      it "blocks self-approval" do
        req = create_requisition(requester_id: "NURSE-001")
        expect {
          described_class.call(requisition: req, action: "approve", actor_id: "NURSE-001")
        }.to raise_error(Dental::Errors::GuardViolation)
      end
    end

    context "dispense" do
      it "dispenses with valid dispense number" do
        req = create_requisition(status: "approved", approver_id: "HEAD-001", approved_at: Time.current)
        result = described_class.call(
          requisition: req,
          action: "dispense",
          actor_id: "PHARM-001",
          params: { dispense_number: "DISP-100" }
        )
        expect(result[:requisition].reload).to be_dispensed
        expect(result[:requisition].dispense_number).to eq("DISP-100")
      end

      it "blocks dispense without dispense number" do
        req = create_requisition(status: "approved", approver_id: "HEAD-001", approved_at: Time.current)
        expect {
          described_class.call(
            requisition: req,
            action: "dispense",
            actor_id: "PHARM-001",
            params: { dispense_number: "" }
          )
        }.to raise_error(Dental::Errors::GuardViolation)
      end
    end

    context "receive" do
      it "receives a dispensed requisition" do
        req = create_requisition(
          status: "dispensed",
          approver_id: "HEAD-001",
          approved_at: Time.current,
          dispenser_id: "PHARM-001",
          dispense_number: "DISP-100",
          dispensed_at: Time.current
        )
        result = described_class.call(requisition: req, action: "receive", actor_id: "NURSE-001")
        expect(result[:requisition].reload).to be_received
      end
    end

    context "cancel" do
      it "cancels a pending requisition with reason" do
        req = create_requisition
        result = described_class.call(
          requisition: req,
          action: "cancel",
          actor_id: "NURSE-001",
          params: { reason: "No longer needed" }
        )
        expect(result[:requisition].reload).to be_cancelled
        expect(result[:requisition].cancel_reason).to eq("No longer needed")
      end
    end

    context "unknown action" do
      it "raises validation error" do
        req = create_requisition
        expect {
          described_class.call(requisition: req, action: "unknown", actor_id: "NURSE-001")
        }.to raise_error(Dental::Errors::ValidationError)
      end
    end
  end
end
