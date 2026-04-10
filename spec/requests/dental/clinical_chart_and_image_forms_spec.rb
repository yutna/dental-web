require "rails_helper"

RSpec.describe "Dental clinical chart and image forms", type: :request do
  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }
  end

  it "saves chart form and writes chart projection rows" do
    expect do
      patch "/en/dental/clinical/visits/VISIT-CH-1/chart", params: {
        patient_hn: "HN-CH-1",
        charts: [
          {
            tooth_code: "11",
            charting_code: "CARIES",
            surface_codes: [ "M", "D" ],
            root_codes: [],
            piece_codes: [],
            note: "new lesion"
          }
        ]
      }
    end.to change(DentalClinicalChartRecord, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-CH-1",
      "projection_count" => 1,
      "payload" => include(
        "charts" => include(
          include("tooth_code" => "11", "charting_code" => "CARIES")
        )
      )
    )
  end

  it "returns validation error when chart anatomy is missing" do
    patch "/en/dental/clinical/visits/VISIT-CH-2/chart", params: {
      patient_hn: "HN-CH-2",
      charts: [
        {
          tooth_code: "16",
          charting_code: "RESTORATION",
          surface_codes: [],
          root_codes: [],
          piece_codes: []
        }
      ]
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to include(
      "error" => include(
        "code" => Dental::ErrorCode::VALIDATION_ERROR,
        "details" => include(
          "form_type" => "dental_chart",
          "field" => "anatomy_codes"
        )
      )
    )
  end

  it "loads latest chart payload for visit" do
    DentalClinicalPost.create!(
      visit_id: "VISIT-CH-3",
      patient_hn: "HN-CH-3",
      form_type: "dental_chart",
      stage: "in-treatment",
      posted_by_id: "user-1",
      posted_at: Time.current,
      payload_json: {
        charts: [
          {
            tooth_code: "26",
            charting_code: "FILLING",
            surface_codes: [ "O" ]
          }
        ]
      }.to_json
    )

    get "/en/dental/clinical/visits/VISIT-CH-3/chart"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-CH-3",
      "form_type" => "dental_chart",
      "exists" => true
    )
  end

  it "saves image form and writes image projection rows" do
    expect do
      patch "/en/dental/clinical/visits/VISIT-IMG-1/images", params: {
        patient_hn: "HN-IMG-1",
        images: [
          {
            image_type_code: "XRAY",
            image_ref: "blob://xray-1",
            note: "bitewing"
          }
        ]
      }
    end.to change(DentalClinicalImageRecord, :count).by(1)

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-IMG-1",
      "projection_count" => 1,
      "payload" => include(
        "images" => include(
          include("image_type_code" => "XRAY", "image_ref" => "blob://xray-1")
        )
      )
    )
  end

  it "returns validation error when required image fields are missing" do
    patch "/en/dental/clinical/visits/VISIT-IMG-2/images", params: {
      patient_hn: "HN-IMG-2",
      images: [
        {
          image_type_code: "",
          image_ref: ""
        }
      ]
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to include(
      "error" => include(
        "code" => Dental::ErrorCode::VALIDATION_ERROR,
        "details" => include(
          "form_type" => "dental_image"
        )
      )
    )
  end

  it "loads latest image payload for visit" do
    DentalClinicalPost.create!(
      visit_id: "VISIT-IMG-3",
      patient_hn: "HN-IMG-3",
      form_type: "dental_image",
      stage: "in-treatment",
      posted_by_id: "user-1",
      posted_at: Time.current,
      payload_json: {
        images: [
          {
            image_type_code: "PHOTO",
            image_ref: "blob://photo-1"
          }
        ]
      }.to_json
    )

    get "/en/dental/clinical/visits/VISIT-IMG-3/images"

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "visit_id" => "VISIT-IMG-3",
      "form_type" => "dental_image",
      "exists" => true
    )
  end
end
