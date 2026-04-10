require "rails_helper"

RSpec.describe "Dental workflow transition guards", type: :request do
  before do
    post "/en/session", params: { username: "admin.test", password: "secret" }
  end

  it "blocks checked-in to screening when room is unavailable" do
    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "checked-in",
      to_stage: "screening",
      room_available: false
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to include(
      "error" => include(
        "code" => Dental::ErrorCode::STATE_GUARD_VIOLATION,
        "message" => "No examination room available",
        "details" => include(
          "guard" => "room_availability",
          "from_stage" => "checked-in",
          "to_stage" => "screening"
        )
      )
    )
  end

  it "blocks screening to ready-for-treatment when required vitals are missing" do
    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "screening",
      to_stage: "ready-for-treatment",
      vitals: { blood_pressure: "120/80" }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to include(
      "error" => include(
        "code" => Dental::ErrorCode::STATE_GUARD_VIOLATION,
        "message" => "Please complete vital signs before continuing",
        "details" => include(
          "guard" => "vitals_required",
          "missing_vitals" => contain_exactly("pulse", "weight")
        )
      )
    )
  end

  it "blocks ready-for-treatment to in-treatment when dentist assignment is missing" do
    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "ready-for-treatment",
      to_stage: "in-treatment"
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.parsed_body).to include(
      "error" => include(
        "code" => Dental::ErrorCode::STATE_GUARD_VIOLATION,
        "message" => "Please assign a dentist",
        "details" => include(
          "guard" => "dentist_assignment"
        )
      )
    )
  end

  it "allows transition when guards are satisfied" do
    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "ready-for-treatment",
      to_stage: "in-treatment",
      dentist_id: "DEN-001"
    }

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "transitioned" => true,
      "from_stage" => "ready-for-treatment",
      "to_stage" => "in-treatment"
    )
  end
end
