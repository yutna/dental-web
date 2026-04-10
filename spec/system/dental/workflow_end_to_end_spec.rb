require "rails_helper"

RSpec.describe "Dental workflow end to end", type: :system do
  before do
    driven_by :rack_test
    sign_in_as_admin
  end

  it "creates check-in and surfaces the visit on queue dashboard" do
    response = patch_json(:post, "/en/dental/visits/check_in", {
      visit_id: "VISIT-E2E-001",
      patient_name: "Somchai Jaidee",
      mrn: "HN-E2E-001",
      vn: "VN-E2E-001",
      service: "Scaling"
    })

    expect(response).to include(
      "visit_id" => "VISIT-E2E-001",
      "current_stage" => "checked-in"
    )

    visit "/en/workspace"

    expect(page.status_code).to eq(200)
    expect(page.body).to include("VISIT-E2E-001")
  end

  it "enforces guard validation for screening completion" do
    patch_json(:post, "/en/dental/visits/check_in", {
      visit_id: "VISIT-E2E-002",
      patient_name: "Mali Chai",
      mrn: "HN-E2E-002",
      vn: "VN-E2E-002"
    })

    snapshot = patch_json(:get, "/en/dental/visits/VISIT-E2E-002")

    patch_json(:patch, "/en/dental/visits/VISIT-E2E-002/transition", {
      from_stage: "checked-in",
      to_stage: "screening",
      room_available: true,
      lock_version: snapshot.fetch("lock_version")
    })

    snapshot = patch_json(:get, "/en/dental/visits/VISIT-E2E-002")
    error_response = patch_json(:patch, "/en/dental/visits/VISIT-E2E-002/transition", {
      from_stage: "screening",
      to_stage: "ready-for-treatment",
      vitals: { blood_pressure: "120/80" },
      lock_version: snapshot.fetch("lock_version")
    })

    expect(error_response).to include(
      "error" => include(
        "code" => "STATE_GUARD_VIOLATION",
        "details" => include("guard" => "vitals_required")
      )
    )
  end

  it "returns optimistic conflict for stale transitions and supports no-charge completion" do
    patch_json(:post, "/en/dental/visits/check_in", {
      visit_id: "VISIT-E2E-003",
      patient_name: "Anya P.",
      mrn: "HN-E2E-003",
      vn: "VN-E2E-003"
    })

    initial_snapshot = patch_json(:get, "/en/dental/visits/VISIT-E2E-003")

    patch_json(:patch, "/en/dental/visits/VISIT-E2E-003/transition", {
      from_stage: "checked-in",
      to_stage: "screening",
      room_available: true,
      lock_version: initial_snapshot.fetch("lock_version")
    })

    stale_response = patch_json(:patch, "/en/dental/visits/VISIT-E2E-003/transition", {
      from_stage: "checked-in",
      to_stage: "screening",
      room_available: true,
      lock_version: initial_snapshot.fetch("lock_version")
    })

    expect(stale_response).to include(
      "error" => include(
        "code" => "STALE_UPDATE_CONFLICT"
      )
    )

    screening_snapshot = patch_json(:get, "/en/dental/visits/VISIT-E2E-003")

    patch_json(:patch, "/en/dental/visits/VISIT-E2E-003/transition", {
      from_stage: "screening",
      to_stage: "ready-for-treatment",
      vitals: {
        blood_pressure: "120/80",
        pulse: "72",
        weight: "58"
      },
      lock_version: screening_snapshot.fetch("lock_version")
    })

    ready_snapshot = patch_json(:get, "/en/dental/visits/VISIT-E2E-003")

    patch_json(:patch, "/en/dental/visits/VISIT-E2E-003/transition", {
      from_stage: "ready-for-treatment",
      to_stage: "in-treatment",
      dentist_id: "DEN-001",
      lock_version: ready_snapshot.fetch("lock_version")
    })

    treatment_snapshot = patch_json(:get, "/en/dental/visits/VISIT-E2E-003")
    complete_response = patch_json(:patch, "/en/dental/visits/VISIT-E2E-003/transition", {
      from_stage: "in-treatment",
      to_stage: "completed",
      lock_version: treatment_snapshot.fetch("lock_version")
    })

    expect(complete_response).to include(
      "current_stage" => "completed",
      "payment_bridge_hook" => "complete_no_charge"
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
    page.driver.submit(method, path, params)
    JSON.parse(page.body)
  end
end
