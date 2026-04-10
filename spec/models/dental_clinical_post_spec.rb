require "rails_helper"

RSpec.describe DentalClinicalPost, type: :model do
  it "accepts valid attributes and parses payload JSON" do
    post = described_class.create!(
      visit_id: "VISIT-CLINICAL-1",
      patient_hn: "HN-001",
      form_type: "screening",
      stage: "screening",
      posted_by_id: "user-1",
      payload_json: { symptoms: [ "pain" ] }.to_json,
      posted_at: Time.current
    )

    expect(post).to be_persisted
    expect(post.payload).to eq("symptoms" => [ "pain" ])
  end

  it "rejects unsupported form type" do
    post = described_class.new(
      visit_id: "VISIT-CLINICAL-1",
      patient_hn: "HN-001",
      form_type: "unsupported",
      posted_by_id: "user-1",
      posted_at: Time.current
    )

    expect(post).not_to be_valid
    expect(post.errors[:form_type]).to be_present
  end
end
