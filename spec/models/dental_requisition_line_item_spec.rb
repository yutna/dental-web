require "rails_helper"

RSpec.describe DentalRequisitionLineItem, type: :model do
  def create_requisition
    DentalRequisition.create!(
      requisition_id: "REQ-#{SecureRandom.hex(4).upcase}",
      requester_id: "NURSE-001",
      status: "pending"
    )
  end

  def build_line_item(overrides = {})
    DentalRequisitionLineItem.new({
      dental_requisition: create_requisition,
      item_type: "medication",
      item_code: "MED-100",
      item_name: "Lidocaine 2%",
      quantity: 10,
      unit: "vial"
    }.merge(overrides))
  end

  describe "validations" do
    it "is valid with complete attributes" do
      expect(build_line_item).to be_valid
    end

    it "requires item_type in allowed values" do
      item = build_line_item(item_type: "invalid")
      expect(item).not_to be_valid
    end

    it "requires item_code" do
      item = build_line_item(item_code: nil)
      expect(item).not_to be_valid
    end

    it "requires quantity > 0" do
      item = build_line_item(quantity: 0)
      expect(item).not_to be_valid
    end

    it "requires unit" do
      item = build_line_item(unit: nil)
      expect(item).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to dental_requisition" do
      req = create_requisition
      item = DentalRequisitionLineItem.create!(
        dental_requisition: req,
        item_type: "supply",
        item_code: "SUP-200",
        item_name: "Gauze Pack",
        quantity: 5,
        unit: "pack"
      )
      expect(item.dental_requisition).to eq(req)
      expect(req.line_items).to include(item)
    end
  end
end
