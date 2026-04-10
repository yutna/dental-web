require "rails_helper"

RSpec.describe Dental::BaseController, type: :controller do
  describe "#http_status_for" do
    it "maps FORBIDDEN to forbidden" do
      status = described_class.new.send(:http_status_for, Dental::ErrorCode::FORBIDDEN)
      expect(status).to eq(:forbidden)
    end

    it "maps INVALID_STAGE_TRANSITION to unprocessable_content" do
      status = described_class.new.send(:http_status_for, Dental::ErrorCode::INVALID_STAGE_TRANSITION)
      expect(status).to eq(:unprocessable_content)
    end

    it "maps STALE_UPDATE_CONFLICT to conflict" do
      status = described_class.new.send(:http_status_for, Dental::ErrorCode::STALE_UPDATE_CONFLICT)
      expect(status).to eq(:conflict)
    end

    it "maps unknown values to internal_server_error" do
      status = described_class.new.send(:http_status_for, "SOMETHING_UNKNOWN")
      expect(status).to eq(:internal_server_error)
    end
  end
end
