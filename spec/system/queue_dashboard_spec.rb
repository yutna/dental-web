require "rails_helper"

RSpec.describe "Queue dashboard", type: :system do
  before do
    driven_by :rack_test
    sign_in_as_admin
  end

  it "supports searching by HN and patient name" do
    create_queue_entry(visit_id: "VISIT-Q-001", patient_name: "Somchai Jaidee", mrn: "HN-SEARCH-001")
    create_queue_entry(visit_id: "VISIT-Q-002", patient_name: "Mali Chai", mrn: "HN-SEARCH-002")

    visit "/en/workspace"

    fill_in "search", with: "HN-SEARCH-001"
    click_button "Apply"

    expect(page).to have_text("Somchai Jaidee")
    expect(page).not_to have_text("Mali Chai")

    fill_in "search", with: "Mali"
    click_button "Apply"

    expect(page).to have_text("Mali Chai")
    expect(page).not_to have_text("Somchai Jaidee")
  end

  it "changes result set when filtering by stage status" do
    create_queue_entry(
      visit_id: "VISIT-Q-010",
      patient_name: "Ready Case",
      mrn: "HN-FILTER-001",
      status: "ready"
    )
    create_queue_entry(
      visit_id: "VISIT-Q-011",
      patient_name: "Completed Case",
      mrn: "HN-FILTER-002",
      status: "completed"
    )

    visit "/en/workspace"

    select "Completed", from: "status"
    click_button "Apply"

    expect(page).to have_text("Completed Case")
    expect(page).not_to have_text("Ready Case")
  end

  it "refreshes dashboard data via retry and allows transition workflow entry from dashboard" do
    entry = create_queue_entry(
      visit_id: "VISIT-Q-020",
      patient_name: "Refresh Candidate",
      mrn: "HN-REFRESH-001",
      status: "scheduled"
    )
    seed_checked_in_timeline(visit_id: entry.visit_id)

    visit "/en/workspace?search=VISIT-Q-020&status=scheduled"

    expect(page).to have_link("Retry")
    expect(page).to have_text("Refresh Candidate")

    entry.update!(patient_name: "Refresh Updated")
    click_link "Retry"

    expect(page).to have_text("Refresh Updated")

    click_link "VISIT-Q-020"

    expect(page).to have_current_path("/en/dental/visits/VISIT-Q-020")
    expect(page).to have_button("Screening")

    click_button "Screening"

    expect(page).to have_text("Transition completed")
    expect(page).to have_text("screening")
  end

  private

  def sign_in_as_admin
    visit "/en/session/new"
    fill_in "username", with: "admin.test"
    fill_in "password", with: "secret"
    click_button "Sign in"
  end

  def create_queue_entry(visit_id:, patient_name:, mrn:, status: "in_progress", source: "walk_in")
    DentalQueueEntry.create!(
      visit_id: visit_id,
      patient_name: patient_name,
      mrn: mrn,
      service: "General Consultation",
      starts_at: "09:00",
      status: status,
      source: source
    )
  end

  def seed_checked_in_timeline(visit_id:)
    Dental::Workflow::AppendTimelineEntry.call(
      visit_id: visit_id,
      from_stage: "registered",
      to_stage: "checked-in",
      actor_id: "admin.test",
      metadata: { source: "queue_dashboard_spec" }
    )
  end
end
