require "rails_helper"

RSpec.describe Dental::StatusHelper, type: :helper do
  describe "#stage_badge" do
    it "renders a status badge for a known stage" do
      result = helper.stage_badge("screening")

      expect(result).to include("Screening")
      expect(result).to include("rounded-full")
    end

    it "falls back to titleized stage name when translation is missing" do
      result = helper.stage_badge("unknown_stage")

      expect(result).to include("Unknown Stage")
    end
  end

  describe "#payment_badge" do
    it "returns a span with semantic classes for known status" do
      result = helper.payment_badge("paid")

      expect(result).to include("Paid")
      expect(result).to include("border-border-semantic-success-primary")
    end

    it "returns a span with warning classes for unknown status" do
      result = helper.payment_badge("something_else")

      expect(result).to include("Something Else")
      expect(result).to include("border-border-semantic-warning-primary")
    end

    it "supports custom label" do
      result = helper.payment_badge("pending", label: "Awaiting")

      expect(result).to include("Awaiting")
    end
  end
end
