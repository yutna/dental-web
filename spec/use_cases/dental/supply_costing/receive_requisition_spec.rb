require "rails_helper"

RSpec.describe Dental::SupplyCosting::ReceiveRequisition, type: :use_case do
  def create_dispensed_requisition(line_items_attrs: [])
    req = DentalRequisition.create!(
      requisition_id: "REQ-#{SecureRandom.hex(4).upcase}",
      requester_id: "NURSE-001",
      approver_id: "HEAD-001",
      dispenser_id: "PHARM-001",
      dispense_number: "DISP-100",
      status: "dispensed",
      approved_at: 1.hour.ago,
      dispensed_at: 30.minutes.ago
    )

    line_items_attrs.each do |attrs|
      req.line_items.create!(attrs)
    end

    req
  end

  describe "#call" do
    it "transitions requisition to received and creates stock-in movements" do
      req = create_dispensed_requisition(line_items_attrs: [
        { item_type: "medication", item_code: "MED-100", item_name: "Lidocaine 2%", quantity: 10, unit: "vial" },
        { item_type: "supply", item_code: "SUP-200", item_name: "Gauze Pack", quantity: 30, unit: "pack" }
      ])

      result = described_class.call(requisition: req, receiver_id: "NURSE-001")

      expect(result[:requisition].reload).to be_received
      expect(result[:requisition].receiver_id).to eq("NURSE-001")
      expect(result[:movements].size).to eq(2)

      result[:movements].each do |movement|
        expect(movement.direction).to eq("in")
        expect(movement.source).to eq("requisition")
        expect(movement.reference_type).to eq("requisition")
        expect(movement.reference_id).to start_with(req.requisition_id)
        expect(movement.movement_ref).to start_with("MOV-IN-")
      end

      expect(result[:movements].map(&:id).uniq.size).to eq(2)
    end

    it "creates no movements for requisition with no line items" do
      req = create_dispensed_requisition
      result = described_class.call(requisition: req, receiver_id: "NURSE-001")

      expect(result[:requisition].reload).to be_received
      expect(result[:movements]).to be_empty
    end

    it "rejects non-dispensed requisitions" do
      req = DentalRequisition.create!(
        requisition_id: "REQ-#{SecureRandom.hex(4).upcase}",
        requester_id: "NURSE-001",
        status: "pending"
      )

      expect {
        described_class.call(requisition: req, receiver_id: "NURSE-001")
      }.to raise_error(Dental::Errors::InvalidTransition)
    end

    it "rolls back everything if stock movement fails" do
      req = create_dispensed_requisition(line_items_attrs: [
        { item_type: "medication", item_code: "MED-100", item_name: "Lidocaine 2%", quantity: 10, unit: "vial" }
      ])

      allow(Dental::SupplyCosting::PostStockMovement).to receive(:call)
        .and_raise(ActiveRecord::RecordInvalid.new(DentalStockMovement.new))

      expect {
        described_class.call(requisition: req, receiver_id: "NURSE-001")
      }.to raise_error(ActiveRecord::RecordInvalid)

      expect(req.reload).to be_dispensed
    end
  end
end
