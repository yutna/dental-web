require "rails_helper"

RSpec.describe Dental::Print::DentalChartQuery do
  let(:visit_id) { "VISIT-DCQ-001" }

  before do
    DentalQueueEntry.create!(
      visit_id: visit_id,
      patient_name: "Boonmee K.",
      mrn: "HN-7001",
      service: "Dental charting",
      starts_at: "11:00",
      status: "in_progress",
      source: "walk_in",
      metadata_json: "{}"
    )

    post = DentalClinicalPost.create!(
      visit_id: visit_id,
      patient_hn: "HN-7001",
      form_type: "dental_chart",
      payload_json: {}.to_json,
      posted_by_id: "dentist-1",
      posted_at: Time.current
    )

    DentalClinicalChartRecord.create!(
      clinical_post: post,
      visit_id: visit_id,
      patient_hn: "HN-7001",
      tooth_code: "11",
      charting_code: "C",
      surface_codes_json: [ "M", "D" ].to_json,
      note: "Caries",
      occurred_at: Time.current
    )

    DentalClinicalChartRecord.create!(
      clinical_post: post,
      visit_id: visit_id,
      patient_hn: "HN-7001",
      tooth_code: "21",
      charting_code: "F",
      surface_codes_json: [ "O" ].to_json,
      note: "Filling",
      occurred_at: Time.current
    )
  end

  it "returns grouped tooth chart entries with counts" do
    result = described_class.call(visit_id: visit_id)

    expect(result[:visit_id]).to eq(visit_id)
    expect(result[:patient_name]).to eq("Boonmee K.")
    expect(result[:total_teeth]).to eq(2)
    expect(result[:total_entries]).to eq(2)
    expect(result[:teeth].keys).to include("11", "21")
    expect(result[:teeth]["11"].first[:charting_code]).to eq("C")
  end

  it "returns empty chart data when no chart records exist" do
    DentalClinicalChartRecord.where(visit_id: visit_id).delete_all

    result = described_class.call(visit_id: visit_id)

    expect(result[:teeth]).to eq({})
    expect(result[:total_teeth]).to eq(0)
    expect(result[:total_entries]).to eq(0)
  end
end
