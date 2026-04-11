require "rails_helper"

RSpec.describe "Dental clinical screening forms", type: :request do
  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }
  end

  it "saves screening form with required vitals" do
    patch "/en/dental/clinical/visits/VISIT-SCR-1/screening", params: {
      patient_hn: "HN-SCR-1",
      vitals: {
        blood_pressure: "120/80",
        pulse: "72",
        weight: "58"
      },
      symptoms: [ "tooth pain" ]
    }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-SCR-1",
      "patient_hn" => "HN-SCR-1"
    )

    post_record = DentalClinicalPost.where(visit_id: "VISIT-SCR-1", form_type: "screening").order(:id).last
    expect(post_record).to be_present
    expect(post_record.payload).to include(
      "vitals" => include("blood_pressure" => "120/80", "pulse" => "72", "weight" => "58")
    )
  end

  it "loads latest screening form payload for visit" do
    DentalClinicalPost.create!(
      visit_id: "VISIT-SCR-2",
      patient_hn: "HN-SCR-2",
      form_type: "screening",
      stage: "screening",
      posted_by_id: "user-1",
      posted_at: Time.current,
      payload_json: {
        vitals: {
          blood_pressure: "118/76",
          pulse: "70",
          weight: "55"
        },
        symptoms: [ "gum bleeding" ]
      }.to_json
    )

    get "/en/dental/clinical/visits/VISIT-SCR-2/screening", as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-SCR-2",
      "form_type" => "screening",
      "exists" => true,
      "payload" => include(
        "vitals" => include("blood_pressure" => "118/76"),
        "symptoms" => [ "gum bleeding" ]
      )
    )
  end

  it "returns validation error when required vitals are missing" do
    patch "/en/dental/clinical/visits/VISIT-SCR-3/screening", params: {
      patient_hn: "HN-SCR-3",
      vitals: {
        blood_pressure: "120/80"
      }
    }, as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to include(
      "error" => include(
        "code" => Dental::ErrorCode::VALIDATION_ERROR,
        "message" => "Please complete required screening fields",
        "details" => include(
          "form_type" => "screening",
          "missing_fields" => contain_exactly("pulse", "weight")
        )
      )
    )
  end
end
