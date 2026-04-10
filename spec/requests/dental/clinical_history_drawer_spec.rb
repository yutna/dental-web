require "rails_helper"

RSpec.describe "Dental clinical history drawer", type: :request do
  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }
  end

  it "returns cumulative tooth map and timeline for patient" do
    post_record = DentalClinicalPost.create!(
      visit_id: "VISIT-HST-1",
      patient_hn: "HN-HST-1",
      form_type: "dental_chart",
      stage: "in-treatment",
      posted_by_id: "user-1",
      posted_at: Time.current,
      payload_json: {}.to_json
    )

    DentalClinicalChartRecord.create!(
      clinical_post_id: post_record.id,
      visit_id: "VISIT-HST-1",
      patient_hn: "HN-HST-1",
      occurred_at: 1.day.ago,
      tooth_code: "11",
      charting_code: "CARIES",
      surface_codes_json: [ "M" ].to_json,
      root_codes_json: [].to_json,
      piece_codes_json: [].to_json,
      note: "chart note"
    )

    DentalClinicalProcedureRecord.create!(
      clinical_post_id: post_record.id,
      visit_id: "VISIT-HST-0",
      patient_hn: "HN-HST-1",
      occurred_at: Time.current,
      tooth_code: "11",
      procedure_item_code: "PROC-001",
      surface_codes_json: [ "O" ].to_json,
      note: "procedure note"
    )

    DentalClinicalImageRecord.create!(
      clinical_post_id: post_record.id,
      visit_id: "VISIT-HST-0",
      patient_hn: "HN-HST-1",
      captured_at: Time.current,
      image_type_code: "XRAY",
      image_ref: "blob://xray-hst-1",
      note: "image note"
    )

    get "/en/dental/clinical/visits/VISIT-HST-1/history", as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-HST-1",
      "patient_hn" => "HN-HST-1",
      "tooth_map" => include(
        include(
          "tooth_code" => "11",
          "chart_count" => 1,
          "procedure_count" => 1
        )
      ),
      "timeline" => include(
        include("entry_type" => "chart", "code" => "CARIES"),
        include("entry_type" => "procedure", "code" => "PROC-001"),
        include("entry_type" => "image", "code" => "XRAY")
      )
    )
  end

  it "returns empty structures when visit has no patient history" do
    get "/en/dental/clinical/visits/VISIT-HST-EMPTY/history", as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-HST-EMPTY",
      "patient_hn" => nil,
      "tooth_map" => [],
      "timeline" => []
    )
  end
end
