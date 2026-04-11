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
    expect(page.body).to include("Source")
    expect(page.body).to include("Retry")
  end

  it "syncs appointments to queue and supports dashboard source filtering" do
    sync_response = patch_json(:post, "/en/dental/visits/sync_appointments")

    expect(sync_response).to include(
      "synced" => true,
      "created_registered_visits" => 4,
      "skipped_duplicates" => 0,
      "error_count" => 0
    )

    visit "/en/workspace?status=scheduled&source=appointment_sync"

    expect(page.status_code).to eq(200)
    expect(page.body).to include("SYNC-AP-1001")
    expect(page.body).to include("Appointment sync")
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

  it "emits payment bridge hooks for waiting-payment, referred-out, and cancelled paths" do
    patch_json(:post, "/en/dental/visits/check_in", {
      visit_id: "VISIT-E2E-004",
      patient_name: "Preecha N.",
      mrn: "HN-E2E-004",
      vn: "VN-E2E-004"
    })

    move_visit_to_in_treatment("VISIT-E2E-004")
    waiting_payment_response = transition_with_latest_lock("VISIT-E2E-004", "in-treatment", "waiting-payment")

    expect(waiting_payment_response).to include(
      "current_stage" => "waiting-payment",
      "payment_bridge_hook" => "send_to_cashier"
    )

    patch_json(:post, "/en/dental/visits/check_in", {
      visit_id: "VISIT-E2E-005",
      patient_name: "Kanya R.",
      mrn: "HN-E2E-005",
      vn: "VN-E2E-005"
    })

    move_visit_to_in_treatment("VISIT-E2E-005")
    referred_response = transition_with_latest_lock("VISIT-E2E-005", "in-treatment", "referred-out")

    expect(referred_response).to include(
      "current_stage" => "referred-out",
      "payment_bridge_hook" => "refer_out"
    )

    patch_json(:post, "/en/dental/visits/check_in", {
      visit_id: "VISIT-E2E-006",
      patient_name: "Nida P.",
      mrn: "HN-E2E-006",
      vn: "VN-E2E-006"
    })

    cancelled_response = transition_with_latest_lock("VISIT-E2E-006", "checked-in", "cancelled")

    expect(cancelled_response).to include(
      "current_stage" => "cancelled",
      "payment_bridge_hook" => "cancel_visit"
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

  def transition_with_latest_lock(visit_id, from_stage, to_stage, extra_params = {})
    snapshot = patch_json(:get, "/en/dental/visits/#{visit_id}")

    patch_json(:patch, "/en/dental/visits/#{visit_id}/transition", {
      from_stage: from_stage,
      to_stage: to_stage,
      lock_version: snapshot.fetch("lock_version")
    }.merge(extra_params))
  end

  def move_visit_to_in_treatment(visit_id)
    transition_with_latest_lock(visit_id, "checked-in", "screening", room_available: true)
    transition_with_latest_lock(
      visit_id,
      "screening",
      "ready-for-treatment",
      vitals: {
        blood_pressure: "120/80",
        pulse: "74",
        weight: "60"
      }
    )
    transition_with_latest_lock(visit_id, "ready-for-treatment", "in-treatment", dentist_id: "DEN-001")
  end
end
