require "rails_helper"

RSpec.describe "Dental clinical projection models", type: :model do
  let(:clinical_post) do
    DentalClinicalPost.create!(
      visit_id: "VISIT-CLINICAL-1",
      patient_hn: "HN-001",
      form_type: "procedure",
      posted_by_id: "user-1",
      payload_json: {}.to_json,
      posted_at: Time.current
    )
  end

  it "persists chart records linked to clinical post" do
    record = DentalClinicalChartRecord.create!(
      clinical_post: clinical_post,
      visit_id: "VISIT-CLINICAL-1",
      patient_hn: "HN-001",
      tooth_code: "11",
      charting_code: "caries",
      surface_codes_json: [ "M", "D" ].to_json,
      occurred_at: Time.current
    )

    expect(record.surface_codes).to contain_exactly("M", "D")
    expect(record.clinical_post).to eq(clinical_post)
  end

  it "persists procedure records linked to clinical post" do
    record = DentalClinicalProcedureRecord.create!(
      clinical_post: clinical_post,
      visit_id: "VISIT-CLINICAL-1",
      patient_hn: "HN-001",
      procedure_item_code: "PROC-001",
      tooth_code: "11",
      quantity: 1,
      occurred_at: Time.current
    )

    expect(record.quantity.to_f).to eq(1.0)
    expect(record.clinical_post).to eq(clinical_post)
  end

  it "persists image records linked to clinical post" do
    record = DentalClinicalImageRecord.create!(
      clinical_post: clinical_post,
      visit_id: "VISIT-CLINICAL-1",
      patient_hn: "HN-001",
      image_type_code: "XRAY",
      image_ref: "active_storage://blob/abc",
      captured_at: Time.current
    )

    expect(record.image_ref).to eq("active_storage://blob/abc")
    expect(record.clinical_post).to eq(clinical_post)
  end
end
