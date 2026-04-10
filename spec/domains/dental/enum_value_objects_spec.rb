require "rails_helper"

RSpec.describe Dental::EnumValue do
  describe "subclasses" do
    it "normalizes input case" do
      value = Dental::Enums::StockDirection.new("IN")
      expect(value.value).to eq("in")
    end

    it "rejects unsupported values" do
      expect do
        Dental::Enums::VisitStage.new("queued")
      end.to raise_error(ArgumentError, /must be one of/)
    end

    it "supports equality by class and value" do
      left = Dental::Enums::UsageStatus.new("failed")
      right = Dental::Enums::UsageStatus.new("FAILED")

      expect(left).to eq(right)
      expect(left.hash).to eq(right.hash)
    end
  end

  describe "catalogs" do
    it "defines visit stages" do
      expect(Dental::Enums::VisitStage.values).to contain_exactly(
        "registered",
        "checked-in",
        "screening",
        "ready-for-treatment",
        "in-treatment",
        "waiting-payment",
        "completed",
        "referred-out",
        "cancelled"
      )
    end

    it "defines payment statuses" do
      expect(Dental::Enums::PaymentStatus.values).to contain_exactly("pending", "paid", "not-required")
    end

    it "defines usage statuses" do
      expect(Dental::Enums::UsageStatus.values).to contain_exactly("pending_deduct", "deducted", "failed")
    end

    it "defines requisition statuses" do
      expect(Dental::Enums::RequisitionStatus.values).to contain_exactly(
        "pending",
        "approved",
        "dispensed",
        "received",
        "cancelled"
      )
    end

    it "defines stock source values" do
      expect(Dental::Enums::StockSource.values).to contain_exactly("pharmacy", "requisition", "adjustment")
    end

    it "defines stock directions" do
      expect(Dental::Enums::StockDirection.values).to contain_exactly("in", "out")
    end
  end
end
