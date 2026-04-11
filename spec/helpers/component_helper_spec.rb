require "rails_helper"

RSpec.describe ComponentHelper, type: :helper do
  describe "#data_table_column" do
    it "returns a column definition hash with defaults" do
      col = helper.data_table_column(:name, "Patient name")

      expect(col).to eq(key: :name, label: "Patient name", sortable: false, align: "left")
    end

    it "accepts sortable and align options" do
      col = helper.data_table_column(:amount, "Amount", sortable: true, align: "right")

      expect(col).to eq(key: :amount, label: "Amount", sortable: true, align: "right")
    end

    it "passes through extra keyword arguments" do
      col = helper.data_table_column(:code, "Code", class: "w-24")

      expect(col[:class]).to eq("w-24")
    end
  end
end
