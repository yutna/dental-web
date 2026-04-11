require "rails_helper"

RSpec.describe "Dental clinical forms and history", type: :system do
  before do
    driven_by :rack_test
    sign_in_as_admin
  end

  it "saves core clinical forms and exposes cumulative history" do
    patch_json(:patch, "/en/dental/clinical/visits/VISIT-CLN-001/screening", {
      patient_hn: "HN-CLN-001",
      vitals: {
        blood_pressure: "118/76",
        pulse: "70",
        weight: "57"
      },
      symptoms: [ "tooth pain" ]
    })

    patch_json(:patch, "/en/dental/clinical/visits/VISIT-CLN-001/treatment", {
      patient_hn: "HN-CLN-001",
      procedures: [
        {
          procedure_item_code: "PROC-100",
          tooth_code: "16",
          surface_codes: [ "M", "O" ],
          quantity: 1
        }
      ]
    })

    patch_json(:patch, "/en/dental/clinical/visits/VISIT-CLN-001/medication", {
      patient_hn: "HN-CLN-001",
      medications: [
        {
          medication_code: "MED-100",
          quantity: 1
        }
      ]
    })

    patch_json(:patch, "/en/dental/clinical/visits/VISIT-CLN-001/chart", {
      patient_hn: "HN-CLN-001",
      charts: [
        {
          tooth_code: "16",
          charting_code: "CARIES",
          surface_codes: [ "O" ]
        }
      ]
    })

    patch_json(:patch, "/en/dental/clinical/visits/VISIT-CLN-001/images", {
      patient_hn: "HN-CLN-001",
      images: [
        {
          image_type_code: "XRAY",
          image_ref: "blob://xray-cln-001"
        }
      ]
    })

    history_response = patch_json(:get, "/en/dental/clinical/visits/VISIT-CLN-001/history.json", {})

    expect(history_response).to include(
      "patient_hn" => "HN-CLN-001",
      "tooth_map" => include(include("tooth_code" => "16")),
      "timeline" => include(
        include("entry_type" => "chart"),
        include("entry_type" => "procedure"),
        include("entry_type" => "image")
      )
    )

    visit "/en/dental/clinical/visits/VISIT-CLN-001/history"

    expect(page.status_code).to eq(200)
    expect(page.body).to include("Cumulative Clinical History")
    expect(page.body).to include("Tooth Map")
    expect(page.body).to include("Timeline")
  end

  it "blocks medication save on allergy conflict until override reason is provided" do
    conflict = patch_json(:patch, "/en/dental/clinical/visits/VISIT-CLN-002/medication", {
      patient_hn: "HN-CLN-002",
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

    expect(conflict).to include(
      "error" => include(
        "code" => "VALIDATION_ERROR",
        "details" => include("requires_override" => true)
      )
    )

    override = patch_json(:patch, "/en/dental/clinical/visits/VISIT-CLN-002/medication", {
      patient_hn: "HN-CLN-002",
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

    expect(override).to include(
      "visit_id" => "VISIT-CLN-002",
      "payload" => include("allergy_override_reason" => "benefit outweighs risk")
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
