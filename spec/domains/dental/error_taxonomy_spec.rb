require "rails_helper"

RSpec.describe Dental::ErrorCode do
  describe "::ALL" do
    it "contains the canonical error catalog" do
      expect(described_class::ALL).to contain_exactly(
        "NOT_FOUND",
        "VALIDATION_ERROR",
        "INVALID_STAGE_TRANSITION",
        "STATE_GUARD_VIOLATION",
        "INSUFFICIENT_STOCK",
        "DUPLICATE_ENTRY",
        "STALE_UPDATE_CONFLICT",
        "UNAUTHORIZED",
        "FORBIDDEN",
        "CONTRACT_MISMATCH",
        "EXTERNAL_INTEGRATION_UNAVAILABLE"
      )
    end

    it "contains unique values" do
      expect(described_class::ALL).to eq(described_class::ALL.uniq)
    end
  end
end

RSpec.describe Dental::Errors::BaseError do
  describe "#to_h" do
    it "exports code, message, and details" do
      error = Dental::Errors::GuardViolation.new(
        message: "Vitals missing",
        details: { field: "blood_pressure" }
      )

      expect(error.to_h).to eq(
        code: Dental::ErrorCode::STATE_GUARD_VIOLATION,
        message: "Vitals missing",
        details: { "field" => "blood_pressure" }
      )
    end
  end
end

RSpec.describe Dental::Errors do
  it "maps InvalidTransition to INVALID_STAGE_TRANSITION" do
    expect(Dental::Errors::InvalidTransition.new.code).to eq(Dental::ErrorCode::INVALID_STAGE_TRANSITION)
  end

  it "maps GuardViolation to STATE_GUARD_VIOLATION" do
    expect(Dental::Errors::GuardViolation.new.code).to eq(Dental::ErrorCode::STATE_GUARD_VIOLATION)
  end

  it "maps InsufficientStock to INSUFFICIENT_STOCK" do
    expect(Dental::Errors::InsufficientStock.new.code).to eq(Dental::ErrorCode::INSUFFICIENT_STOCK)
  end

  it "maps StageUpdateConflict to STALE_UPDATE_CONFLICT" do
    expect(Dental::Errors::StageUpdateConflict.new.code).to eq(Dental::ErrorCode::STALE_UPDATE_CONFLICT)
  end

  it "maps ContractMismatch to CONTRACT_MISMATCH" do
    expect(Dental::Errors::ContractMismatch.new.code).to eq(Dental::ErrorCode::CONTRACT_MISMATCH)
  end

  it "maps ExternalIntegrationUnavailable to EXTERNAL_INTEGRATION_UNAVAILABLE" do
    expect(Dental::Errors::ExternalIntegrationUnavailable.new.code).to eq(Dental::ErrorCode::EXTERNAL_INTEGRATION_UNAVAILABLE)
  end
end
