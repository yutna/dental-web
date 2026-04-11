require "rails_helper"

RSpec.describe "Clinical forms enterprise", type: :system do
  before do
    driven_by :rack_test
    sign_in_as_admin
  end

  it "completes screening and treatment flow and exposes cumulative history" do
    patch_json(:patch, "/en/dental/clinical/visits/VISIT-ENT-CLN-001/screening", {
      patient_hn: "HN-ENT-001",
      vitals: {
        blood_pressure: "120/80",
        pulse: "72",
        weight: "58"
      },
      symptoms: [ "tooth pain" ]
    })

    patch_json(:patch, "/en/dental/clinical/visits/VISIT-ENT-CLN-001/treatment", {
      patient_hn: "HN-ENT-001",
      procedures: [
        {
          procedure_item_code: "PROC-100",
          tooth_code: "16",
          surface_codes: [ "M", "O" ],
          quantity: 1
        }
      ]
    })

    history = patch_json(:get, "/en/dental/clinical/visits/VISIT-ENT-CLN-001/history.json", {})

    expect(history).to include(
      "patient_hn" => "HN-ENT-001",
      "timeline" => include(
        include("entry_type" => "procedure")
      ),
      "tooth_map" => include(include("tooth_code" => "16"))
    )

    visit "/en/dental/clinical/visits/VISIT-ENT-CLN-001/history"

    expect(page).to have_text("Cumulative Clinical History")
    expect(page).to have_text("Timeline")
  end

  it "blocks high-alert and allergy-conflicting medication until required confirmations are provided" do
    DentalMedicationProfile.create!(
      code: "AMOX-500",
      name: "Amoxicillin 500 mg",
      category: "high_alert",
      active: true
    )

    high_alert_conflict = patch_json(:patch, "/en/dental/clinical/visits/VISIT-ENT-CLN-002/medication", {
      patient_hn: "HN-ENT-002",
      medications: [
        {
          medication_code: "AMOX-500",
          quantity: 1
        }
      ]
    })

    expect(high_alert_conflict).to include(
      "error" => include(
        "code" => "VALIDATION_ERROR",
        "details" => include(
          "requires_confirmation" => true,
          "high_alert_codes" => include("AMOX-500")
        )
      )
    )

    allergy_conflict = patch_json(:patch, "/en/dental/clinical/visits/VISIT-ENT-CLN-002/medication", {
      patient_hn: "HN-ENT-002",
      confirm_high_alert: true,
      medications: [
        {
          medication_code: "AMOX-500",
          quantity: 1
        }
      ],
      allergies: [
        {
          medication_code: "AMOX-500",
          reaction: "severe rash"
        }
      ]
    })

    expect(allergy_conflict).to include(
      "error" => include(
        "code" => "VALIDATION_ERROR",
        "details" => include("requires_override" => true)
      )
    )

    success = patch_json(:patch, "/en/dental/clinical/visits/VISIT-ENT-CLN-002/medication", {
      patient_hn: "HN-ENT-002",
      confirm_high_alert: true,
      allergy_override_reason: "benefit outweighs risk",
      medications: [
        {
          medication_code: "AMOX-500",
          quantity: 1
        }
      ],
      allergies: [
        {
          medication_code: "AMOX-500",
          reaction: "severe rash"
        }
      ]
    })

    expect(success).to include(
      "visit_id" => "VISIT-ENT-CLN-002",
      "payload" => include(
        "confirm_high_alert" => true,
        "allergy_override_reason" => "benefit outweighs risk"
      )
    )
  end

  private

  def sign_in_as_admin
    visit "/en/session/new"
    fill_in "username", with: "admin.test"
    fill_in "password", with: "secret"
    click_button "Sign in"
  end

  def patch_json(method, path, params = {})
    json_path = path.include?(".json") ? path : "#{path}.json"
    page.driver.submit(method, json_path, params)
    JSON.parse(page.body)
  end
end
