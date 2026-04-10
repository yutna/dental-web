require "rails_helper"

RSpec.describe Backend::Providers::Dental::Result do
  describe ".success" do
    it "builds a successful result payload" do
      result = described_class.success(payload: { visit_id: "V001" })

      expect(result).to be_ok
      expect(result.failure?).to be(false)
      expect(result.to_h).to eq(
        payload: { "visit_id" => "V001" },
        error_code: nil,
        error_message: nil,
        details: {}
      )
    end
  end

  describe ".failure" do
    it "builds a failed result payload" do
      result = described_class.failure(
        error_code: Dental::ErrorCode::FORBIDDEN,
        error_message: "Forbidden",
        details: { scope: "workflow" }
      )

      expect(result).to be_failure
      expect(result.error_code).to eq(Dental::ErrorCode::FORBIDDEN)
      expect(result.details).to eq({ "scope" => "workflow" })
    end

    it "rejects unknown error codes" do
      expect do
        described_class.failure(error_code: "NOT_IN_CATALOG", error_message: "x")
      end.to raise_error(ArgumentError, /Unknown dental error code/)
    end
  end
end

RSpec.describe Backend::Providers::Dental::WorkflowProvider do
  subject(:provider) { described_class.new }

  it "defines find_visit as an explicit interface" do
    expect { provider.find_visit("visit-1") }.to raise_error(NotImplementedError, /find_visit/)
  end

  it "defines transition_visit as an explicit interface" do
    expect do
      provider.transition_visit(visit_id: "visit-1", to_stage: "screening", metadata: {})
    end.to raise_error(NotImplementedError, /transition_visit/)
  end
end

RSpec.describe Backend::Providers::Dental::MasterDataProvider do
  subject(:provider) { described_class.new }

  it "defines list methods as explicit interfaces" do
    expect { provider.list_procedures(filters: {}) }.to raise_error(NotImplementedError, /list_procedures/)
    expect { provider.list_medications(filters: {}) }.to raise_error(NotImplementedError, /list_medications/)
    expect { provider.list_supplies(filters: {}) }.to raise_error(NotImplementedError, /list_supplies/)
  end
end

RSpec.describe Backend::Providers::Dental::ClinicalProvider do
  subject(:provider) { described_class.new }

  it "defines screening and treatment save interfaces" do
    expect do
      provider.save_screening(visit_id: "visit-1", attributes: {})
    end.to raise_error(NotImplementedError, /save_screening/)

    expect do
      provider.save_treatment(visit_id: "visit-1", attributes: {})
    end.to raise_error(NotImplementedError, /save_treatment/)
  end
end

RSpec.describe Backend::Providers::Dental::SupplyProvider do
  subject(:provider) { described_class.new }

  it "defines usage and requisition interfaces" do
    expect do
      provider.deduct_usage(usage_reference: "usage-1", payload: {})
    end.to raise_error(NotImplementedError, /deduct_usage/)

    expect { provider.create_requisition(payload: {}) }.to raise_error(NotImplementedError, /create_requisition/)
  end
end
