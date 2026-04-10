require "rails_helper"

RSpec.describe "Dental clinical medication forms", type: :request do
  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }
  end

  it "saves medication form when no high-alert medication is present" do
    patch "/en/dental/clinical/visits/VISIT-MED-1/medication", params: {
      patient_hn: "HN-MED-1",
      medications: [
        {
          medication_code: "MED-001",
          quantity: 2,
          note: "after meal"
        }
      ]
    }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-MED-1",
      "patient_hn" => "HN-MED-1",
      "payload" => include(
        "medications" => include(
          include("medication_code" => "MED-001", "quantity" => "2")
        )
      )
    )
  end

  it "requires explicit confirmation for high-alert medication" do
    DentalMedicationProfile.create!(
      code: "HAA-001",
      name: "High Alert A",
      category: "high_alert",
      active: true
    )

    patch "/en/dental/clinical/visits/VISIT-MED-2/medication", params: {
      patient_hn: "HN-MED-2",
      medications: [
        {
          medication_code: "HAA-001",
          quantity: 1,
          note: "monitor closely"
        }
      ]
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to include(
      "error" => include(
        "code" => Dental::ErrorCode::VALIDATION_ERROR,
        "details" => include(
          "form_type" => "medication",
          "requires_confirmation" => true,
          "high_alert_codes" => contain_exactly("HAA-001")
        )
      )
    )
  end

  it "saves high-alert medication form after confirmation" do
    DentalMedicationProfile.create!(
      code: "HAB-001",
      name: "High Alert B",
      category: "high_alert",
      active: true
    )

    patch "/en/dental/clinical/visits/VISIT-MED-3/medication", params: {
      patient_hn: "HN-MED-3",
      confirm_high_alert: true,
      medications: [
        {
          medication_code: "HAB-001",
          quantity: 1,
          note: "double-check dosage"
        }
      ]
    }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-MED-3",
      "payload" => include(
        "confirm_high_alert" => true,
        "medications" => include(
          include("medication_code" => "HAB-001", "quantity" => "1")
        )
      )
    )
  end

  it "loads latest medication payload for visit" do
    DentalClinicalPost.create!(
      visit_id: "VISIT-MED-4",
      patient_hn: "HN-MED-4",
      form_type: "medication",
      stage: "in-treatment",
      posted_by_id: "user-1",
      posted_at: Time.current,
      payload_json: {
        medications: [
          {
            medication_code: "MED-XYZ",
            quantity: 3,
            note: "before sleep"
          }
        ],
        confirm_high_alert: false
      }.to_json
    )

    get "/en/dental/clinical/visits/VISIT-MED-4/medication"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-MED-4",
      "form_type" => "medication",
      "exists" => true,
      "payload" => include(
        "medications" => include(
          include("medication_code" => "MED-XYZ", "quantity" => 3)
        )
      )
    )
  end
end
