require "rails_helper"

RSpec.describe Dental::Workflow::VisitSnapshotQuery do
  it "returns registered stage when no timeline entries exist" do
    result = described_class.call(visit_id: "VISIT-1")

    expect(result).to include(
      visit_id: "VISIT-1",
      current_stage: "registered",
      lock_version: 0,
      last_event_at: nil,
      last_actor_id: nil
    )
  end

  it "returns latest stage and lock version from timeline entries" do
    DentalWorkflowTimelineEntry.create!(
      visit_id: "VISIT-1",
      from_stage: "registered",
      to_stage: "checked-in",
      event_type: "stage_transition",
      actor_id: "user-1",
      metadata_json: {}.to_json,
      created_at: Time.current
    )

    DentalWorkflowTimelineEntry.create!(
      visit_id: "VISIT-1",
      from_stage: "checked-in",
      to_stage: "screening",
      event_type: "stage_transition",
      actor_id: "user-2",
      metadata_json: {}.to_json,
      created_at: Time.current + 1.second
    )

    result = described_class.call(visit_id: "VISIT-1")

    expect(result[:current_stage]).to eq("screening")
    expect(result[:lock_version]).to eq(2)
    expect(result[:last_actor_id]).to eq("user-2")
    expect(result[:last_event_at]).to be_present
  end
end
