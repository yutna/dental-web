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
    }, as: :json

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
    }, as: :json

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
    }, as: :json

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
    before_count = DentalWorkflowTimelineEntry.count

    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "ready-for-treatment",
      to_stage: "in-treatment",
      dentist_id: "DEN-001"
    }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      "transitioned" => true,
      "from_stage" => "ready-for-treatment",
      "to_stage" => "in-treatment",
      "current_stage" => "in-treatment",
      "lock_version" => 1
    )

    expect(DentalWorkflowTimelineEntry.count).to eq(before_count + 1)
    expect(DentalWorkflowTimelineEntry.order(:id).last).to have_attributes(
      visit_id: "VISIT-1",
      from_stage: "ready-for-treatment",
      to_stage: "in-treatment",
      event_type: "stage_transition"
    )
  end

  it "returns conflict when lock_version is stale" do
    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "registered",
      to_stage: "checked-in",
      lock_version: 0
    }, as: :json

    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "checked-in",
      to_stage: "screening",
      room_available: true,
      lock_version: 0
    }, as: :json

    expect(response).to have_http_status(:conflict)
    expect(response.parsed_body).to include(
      "error" => include(
        "code" => Dental::ErrorCode::STALE_UPDATE_CONFLICT,
        "message" => "This visit was updated by another user",
        "details" => include(
          "visit_id" => "VISIT-1",
          "attempted_from_stage" => "checked-in",
          "attempted_to_stage" => "screening",
          "current_stage" => "checked-in",
          "current_lock_version" => 1,
          "expected_lock_version" => 0
        )
      )
    )
  end

  it "emits send_to_cashier bridge hook when transitioning to waiting-payment" do
    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "in-treatment",
      to_stage: "waiting-payment"
    }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("payment_bridge_hook" => "send_to_cashier")

    event = DentalPaymentBridgeEvent.order(:id).last
    expect(event).to have_attributes(
      visit_id: "VISIT-1",
      from_stage: "in-treatment",
      to_stage: "waiting-payment",
      hook_type: "send_to_cashier",
      status: "pending"
    )
  end

  it "emits complete_no_charge bridge hook when transitioning in-treatment to completed" do
    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "in-treatment",
      to_stage: "completed"
    }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("payment_bridge_hook" => "complete_no_charge")
  end

  it "emits refer_out bridge hook when transitioning to referred-out" do
    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "in-treatment",
      to_stage: "referred-out"
    }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("payment_bridge_hook" => "refer_out")
  end

  it "emits cancel_visit bridge hook when transitioning to cancelled" do
    patch "/en/dental/visits/VISIT-1/transition", params: {
      from_stage: "registered",
      to_stage: "cancelled"
    }, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include("payment_bridge_hook" => "cancel_visit")
  end
end
