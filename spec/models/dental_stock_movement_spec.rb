require "rails_helper"

RSpec.describe DentalStockMovement, type: :model do
  def build_movement(overrides = {})
    DentalStockMovement.new({
      movement_ref: "MOV-OUT-#{SecureRandom.hex(4).upcase}",
      item_type: "medication",
      item_code: "MED-100",
      direction: "out",
      quantity: 5,
      unit: "vial",
      source: "pharmacy",
      actor_id: "ACTOR-001"
    }.merge(overrides))
  end

  describe "validations" do
    it "is valid with complete attributes" do
      expect(build_movement).to be_valid
    end

    it "requires movement_ref" do
      record = build_movement(movement_ref: nil)
      expect(record).not_to be_valid
    end

    it "enforces unique movement_ref" do
      build_movement(movement_ref: "MOV-DUP").save!
      dup = build_movement(movement_ref: "MOV-DUP")
      expect(dup).not_to be_valid
    end

    it "requires direction in allowed values" do
      record = build_movement(direction: "sideways")
      expect(record).not_to be_valid
    end

    it "requires quantity > 0" do
      record = build_movement(quantity: 0)
      expect(record).not_to be_valid
    end

    it "requires source in allowed values" do
      record = build_movement(source: "magic")
      expect(record).not_to be_valid
    end

    it "accepts reference_type in allowed values" do
      %w[usage requisition adjustment].each do |ref_type|
        record = build_movement(reference_type: ref_type)
        expect(record).to be_valid
      end
    end

    it "rejects invalid reference_type" do
      record = build_movement(reference_type: "invalid")
      expect(record).not_to be_valid
    end

    it "allows blank reference_type" do
      record = build_movement(reference_type: nil)
      expect(record).to be_valid
    end
  end

  describe "scopes" do
    before do
      build_movement(movement_ref: "MOV-OUT-1", direction: "out").save!
      build_movement(movement_ref: "MOV-IN-1", direction: "in").save!
    end

    it ".outbound returns out movements" do
      expect(DentalStockMovement.outbound.count).to eq(1)
      expect(DentalStockMovement.outbound.first.direction).to eq("out")
    end

    it ".inbound returns in movements" do
      expect(DentalStockMovement.inbound.count).to eq(1)
      expect(DentalStockMovement.inbound.first.direction).to eq("in")
    end

    it ".for_item filters by item_type and item_code" do
      build_movement(movement_ref: "MOV-OTHER", item_code: "MED-999").save!
      expect(DentalStockMovement.for_item("medication", "MED-100").count).to eq(2)
    end
  end

  describe "#out? and #in?" do
    it "returns true for matching direction" do
      out = build_movement(direction: "out")
      expect(out).to be_out
      expect(out).not_to be_in

      inv = build_movement(direction: "in")
      expect(inv).to be_in
      expect(inv).not_to be_out
    end
  end
end
