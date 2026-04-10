require "rails_helper"

RSpec.describe DentalWorkflowTimelineEntry, type: :model do
  it "is append-only and cannot be updated" do
    entry = described_class.create!(
      visit_id: "VISIT-1",
      from_stage: "registered",
      to_stage: "checked-in",
      event_type: "stage_transition",
      actor_id: "user-1",
      metadata_json: {}.to_json,
      created_at: Time.current
    )

    expect(entry.update(to_stage: "screening")).to be(false)
    expect(entry.errors.full_messages.join).to include("append_only")
  end

  it "is append-only and cannot be destroyed" do
    entry = described_class.create!(
      visit_id: "VISIT-1",
      from_stage: "registered",
      to_stage: "checked-in",
      event_type: "stage_transition",
      actor_id: "user-1",
      metadata_json: {}.to_json,
      created_at: Time.current
    )

    expect(entry.destroy).to be(false)
    expect(entry.errors.full_messages.join).to include("append_only")
  end
end
