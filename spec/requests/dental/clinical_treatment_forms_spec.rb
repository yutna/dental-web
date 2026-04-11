require "rails_helper"

RSpec.describe "Dental clinical treatment forms", type: :request do
  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }
  end

  it "saves treatment procedures and writes projection rows" do
    expect do
      patch "/en/dental/clinical/visits/VISIT-TX-1/treatment", params: {
        patient_hn: "HN-TX-1",
        procedures: [
          {
            procedure_item_code: "PROC-001",
            tooth_code: "11",
            surface_codes: [ "M", "D" ],
            quantity: 1
          },
          {
            procedure_item_code: "PROC-002",
            tooth_code: "21",
            surface_codes: [ "O" ],
            quantity: 2
          }
        ]
      }, as: :json
    end.to change(DentalClinicalProcedureRecord, :count).by(2)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-TX-1",
      "patient_hn" => "HN-TX-1",
      "projection_count" => 2
    )
  end

  it "loads latest treatment payload for visit" do
    DentalClinicalPost.create!(
      visit_id: "VISIT-TX-2",
      patient_hn: "HN-TX-2",
      form_type: "treatment",
      stage: "in-treatment",
      posted_by_id: "user-1",
      posted_at: Time.current,
      payload_json: {
        procedures: [
          {
            procedure_item_code: "PROC-XYZ",
            tooth_code: "16",
            surface_codes: [ "M" ]
          }
        ]
      }.to_json
    )

    get "/en/dental/clinical/visits/VISIT-TX-2/treatment", as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-TX-2",
      "form_type" => "treatment",
      "exists" => true,
      "payload" => include(
        "procedures" => include(
          include(
            "procedure_item_code" => "PROC-XYZ",
            "tooth_code" => "16"
          )
        )
      )
    )
  end

  it "returns validation error when tooth or surfaces are missing" do
    patch "/en/dental/clinical/visits/VISIT-TX-3/treatment", params: {
      patient_hn: "HN-TX-3",
      procedures: [
        {
          procedure_item_code: "PROC-001",
          tooth_code: "",
          surface_codes: []
        }
      ]
    }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to include(
      "error" => include(
        "code" => Dental::ErrorCode::VALIDATION_ERROR,
        "details" => include(
          "form_type" => "treatment"
        )
      )
    )
  end
end
