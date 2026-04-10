require "rails_helper"

RSpec.describe Dental::BaseUseCase do
  let(:klass) do
    Class.new(described_class) do
      def call(mode)
        return success(payload: { stage: "registered" }) if mode == :ok

        failure(
          error_code: Dental::ErrorCode::STATE_GUARD_VIOLATION,
          error_message: "Guard failed",
          details: { field: "vitals" }
        )
      end
    end
  end

  it "returns typed success results" do
    result = klass.call(:ok)

    expect(result).to be_a(Backend::Providers::Dental::Result)
    expect(result).to be_ok
    expect(result.payload).to eq({ "stage" => "registered" })
  end

  it "returns typed failure results" do
    result = klass.call(:failed)

    expect(result).to be_failure
    expect(result.error_code).to eq(Dental::ErrorCode::STATE_GUARD_VIOLATION)
    expect(result.error_message).to eq("Guard failed")
    expect(result.details).to eq({ "field" => "vitals" })
  end
end
