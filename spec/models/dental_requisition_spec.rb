require "rails_helper"

RSpec.describe DentalRequisition, type: :model do
  def build_requisition(overrides = {})
    DentalRequisition.new({
      requisition_id: "REQ-#{SecureRandom.hex(4).upcase}",
      requester_id: "NURSE-001",
      status: "pending"
    }.merge(overrides))
  end

  def create_requisition(overrides = {})
    build_requisition(overrides).tap(&:save!)
  end

  describe "validations" do
    it "is valid with complete attributes" do
      expect(build_requisition).to be_valid
    end

    it "requires requisition_id" do
      record = build_requisition(requisition_id: nil)
      expect(record).not_to be_valid
      expect(record.errors[:requisition_id]).to include("can't be blank")
    end

    it "enforces unique requisition_id" do
      create_requisition(requisition_id: "REQ-DUPE")
      duplicate = build_requisition(requisition_id: "REQ-DUPE")
      expect(duplicate).not_to be_valid
    end

    it "requires requester_id" do
      record = build_requisition(requester_id: nil)
      expect(record).not_to be_valid
    end

    it "requires status in allowed values" do
      record = build_requisition(status: "invalid")
      expect(record).not_to be_valid
    end

    it "requires cancel_reason when cancelled" do
      record = build_requisition(status: "cancelled", cancelled_at: Time.current)
      expect(record).not_to be_valid
      expect(record.errors[:cancel_reason]).to include("is required when cancelling a requisition")
    end
  end

  describe "scopes" do
    before do
      create_requisition(status: "pending")
      create_requisition(status: "approved", approver_id: "HEAD-001", approved_at: Time.current)
      create_requisition(status: "cancelled", cancel_reason: "not needed", cancelled_at: Time.current)
    end

    it ".pending returns pending records" do
      expect(DentalRequisition.pending.count).to eq(1)
    end

    it ".active excludes cancelled records" do
      expect(DentalRequisition.active.count).to eq(2)
    end
  end

  describe "#can_transition_to?" do
    it "allows pending -> approved" do
      req = build_requisition(status: "pending")
      expect(req.can_transition_to?("approved")).to be true
    end

    it "allows pending -> cancelled" do
      req = build_requisition(status: "pending")
      expect(req.can_transition_to?("cancelled")).to be true
    end

    it "denies pending -> dispensed" do
      req = build_requisition(status: "pending")
      expect(req.can_transition_to?("dispensed")).to be false
    end

    it "denies received -> anything" do
      req = build_requisition(status: "received", receiver_id: "PHARM-001", received_at: Time.current)
      expect(req.can_transition_to?("cancelled")).to be false
    end
  end

  describe "#approve!" do
    it "transitions from pending to approved" do
      req = create_requisition
      req.approve!(approver_id: "HEAD-001")
      expect(req.reload).to be_approved
      expect(req.approver_id).to eq("HEAD-001")
      expect(req.approved_at).to be_present
    end

    it "blocks self-approval" do
      req = create_requisition(requester_id: "NURSE-001")
      expect {
        req.approve!(approver_id: "NURSE-001")
      }.to raise_error(Dental::Errors::GuardViolation) { |e|
        expect(e.details["message"]).to include("requester cannot approve own requisition")
      }
    end

    it "rejects invalid transition from dispensed" do
      req = create_requisition(
        status: "dispensed",
        approver_id: "HEAD-001",
        approved_at: Time.current,
        dispenser_id: "PHARM-001",
        dispense_number: "DISP-001",
        dispensed_at: Time.current
      )
      expect { req.approve!(approver_id: "HEAD-002") }.to raise_error(Dental::Errors::InvalidTransition)
    end
  end

  describe "#dispense!" do
    it "transitions from approved to dispensed with dispense number" do
      req = create_requisition(status: "approved", approver_id: "HEAD-001", approved_at: Time.current)
      req.dispense!(dispenser_id: "PHARM-001", dispense_number: "DISP-001")
      expect(req.reload).to be_dispensed
      expect(req.dispense_number).to eq("DISP-001")
    end

    it "blocks dispense without dispense number" do
      req = create_requisition(status: "approved", approver_id: "HEAD-001", approved_at: Time.current)
      expect {
        req.dispense!(dispenser_id: "PHARM-001", dispense_number: "")
      }.to raise_error(Dental::Errors::GuardViolation) { |e|
        expect(e.details["message"]).to include("dispense number is required")
      }
    end
  end

  describe "#receive!" do
    it "transitions from dispensed to received" do
      req = create_requisition(
        status: "dispensed",
        approver_id: "HEAD-001",
        approved_at: Time.current,
        dispenser_id: "PHARM-001",
        dispense_number: "DISP-001",
        dispensed_at: Time.current
      )
      req.receive!(receiver_id: "NURSE-001")
      expect(req.reload).to be_received
      expect(req.receiver_id).to eq("NURSE-001")
    end
  end

  describe "#cancel!" do
    it "transitions from pending to cancelled with reason" do
      req = create_requisition
      req.cancel!(reason: "No longer needed")
      expect(req.reload).to be_cancelled
      expect(req.cancel_reason).to eq("No longer needed")
    end

    it "transitions from approved to cancelled" do
      req = create_requisition(status: "approved", approver_id: "HEAD-001", approved_at: Time.current)
      req.cancel!(reason: "Duplicate request")
      expect(req.reload).to be_cancelled
    end

    it "rejects cancel from dispensed" do
      req = create_requisition(
        status: "dispensed",
        approver_id: "HEAD-001",
        approved_at: Time.current,
        dispenser_id: "PHARM-001",
        dispense_number: "DISP-001",
        dispensed_at: Time.current
      )
      expect { req.cancel!(reason: "Too late") }.to raise_error(Dental::Errors::InvalidTransition)
    end
  end

  describe "#terminal?" do
    it "returns true for received" do
      req = build_requisition(status: "received")
      expect(req).to be_terminal
    end

    it "returns true for cancelled" do
      req = build_requisition(status: "cancelled")
      expect(req).to be_terminal
    end

    it "returns false for pending" do
      req = build_requisition(status: "pending")
      expect(req).not_to be_terminal
    end
  end
end
