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

# ---------------------------------------------------------------------------
# Provider interface specs (not-implemented guards)
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Fixture-based contract parity tests
# ---------------------------------------------------------------------------
RSpec.describe "Dental provider contract parity" do
  let(:result_class) { Backend::Providers::Dental::Result }

  shared_examples "matching fixture shape" do |fixture_key, expected_ok:|
    it "matches #{fixture_key} canonical shape" do
      fixture = fixture_data[fixture_key]

      result = if expected_ok
                 result_class.success(payload: fixture["payload"])
               else
                 result_class.failure(
                   error_code: fixture["error_code"],
                   error_message: fixture["error_message"],
                   details: fixture["details"]
                 )
               end

      expect(result.ok?).to eq(expected_ok)
      expect(result.payload).to eq(fixture["payload"].deep_stringify_keys)
      expect(result.error_code).to eq(fixture["error_code"])
      expect(result.error_message).to eq(fixture["error_message"])
      expect(result.details).to eq((fixture["details"] || {}).deep_stringify_keys)
    end
  end

  describe "WorkflowProvider fixture parity" do
    let(:fixture_data) { json_fixture("contracts/dental/workflow_provider.json") }

    include_examples "matching fixture shape", "success", expected_ok: true
    include_examples "matching fixture shape", "failure_not_found", expected_ok: false
    include_examples "matching fixture shape", "failure_invalid_transition", expected_ok: false

    it "success payload contains required visit fields" do
      fixture = fixture_data["success"]["payload"]
      expect(fixture).to have_key("visit_id")
      expect(fixture).to have_key("current_stage")
    end
  end

  describe "ClinicalProvider fixture parity" do
    let(:fixture_data) { json_fixture("contracts/dental/clinical_provider.json") }

    include_examples "matching fixture shape", "success_screening", expected_ok: true
    include_examples "matching fixture shape", "success_treatment", expected_ok: true
    include_examples "matching fixture shape", "failure_validation", expected_ok: false

    it "screening payload contains form_type" do
      fixture = fixture_data["success_screening"]["payload"]
      expect(fixture["form_type"]).to eq("screening")
    end

    it "treatment payload contains procedures array" do
      fixture = fixture_data["success_treatment"]["payload"]
      expect(fixture["procedures"]).to be_an(Array)
      expect(fixture["procedures"].first).to have_key("procedure_item_code")
    end
  end

  describe "MasterDataProvider fixture parity" do
    let(:fixture_data) { json_fixture("contracts/dental/master_data_provider.json") }

    include_examples "matching fixture shape", "success_procedures", expected_ok: true
    include_examples "matching fixture shape", "success_medications", expected_ok: true
    include_examples "matching fixture shape", "success_supplies", expected_ok: true

    %w[success_procedures success_medications success_supplies].each do |key|
      it "#{key} payload has items array with total_count" do
        fixture = fixture_data[key]["payload"]
        expect(fixture["items"]).to be_an(Array)
        expect(fixture["total_count"]).to be_a(Integer)
        expect(fixture["items"].first).to have_key("code")
        expect(fixture["items"].first).to have_key("name_en")
        expect(fixture["items"].first).to have_key("unit_cost")
      end
    end
  end

  describe "SupplyProvider fixture parity" do
    let(:fixture_data) { json_fixture("contracts/dental/supply_provider.json") }

    include_examples "matching fixture shape", "success_deduct_usage", expected_ok: true
    include_examples "matching fixture shape", "success_create_requisition", expected_ok: true
    include_examples "matching fixture shape", "failure_insufficient_stock", expected_ok: false

    it "deduct_usage payload contains reference_id" do
      fixture = fixture_data["success_deduct_usage"]["payload"]
      expect(fixture).to have_key("reference_id")
      expect(fixture).to have_key("items_deducted")
    end

    it "create_requisition payload contains requisition_id" do
      fixture = fixture_data["success_create_requisition"]["payload"]
      expect(fixture).to have_key("requisition_id")
      expect(fixture).to have_key("status")
    end
  end

  describe "All fixtures use valid error codes" do
    %w[
      contracts/dental/workflow_provider.json
      contracts/dental/clinical_provider.json
      contracts/dental/master_data_provider.json
      contracts/dental/supply_provider.json
    ].each do |path|
      context path do
        it "uses only recognized Dental::ErrorCode values" do
          data = json_fixture(path)
          data.each_value do |scenario|
            next unless scenario.is_a?(Hash) && scenario["error_code"].present?

            expect(Dental::ErrorCode::ALL).to include(scenario["error_code"]),
              "Unknown error code #{scenario['error_code']} in #{path}"
          end
        end
      end
    end
  end
end
