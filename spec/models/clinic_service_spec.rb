require "rails_helper"

RSpec.describe ClinicService, type: :model do
  subject(:clinic_service) { build(:clinic_service) }

  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:default_duration_minutes).is_greater_than(0).only_integer }

  it "normalizes code to uppercase" do
    clinic_service.code = " srv-999 "
    clinic_service.validate

    expect(clinic_service.code).to eq("SRV-999")
  end
end
