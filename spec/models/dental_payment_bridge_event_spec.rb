require "rails_helper"

RSpec.describe DentalPaymentBridgeEvent, type: :model do
  it "is append-only and cannot be updated" do
    event = described_class.create!(
      visit_id: "VISIT-1",
      hook_type: "send_to_cashier",
      from_stage: "in-treatment",
      to_stage: "waiting-payment",
      status: "pending",
      payload_json: {}.to_json
    )

    expect(event.update(status: "sent")).to be(false)
    expect(event.errors.full_messages.join).to include("append_only")
  end

  it "is append-only and cannot be destroyed" do
    event = described_class.create!(
      visit_id: "VISIT-1",
      hook_type: "send_to_cashier",
      from_stage: "in-treatment",
      to_stage: "waiting-payment",
      status: "pending",
      payload_json: {}.to_json
    )

    expect(event.destroy).to be(false)
    expect(event.errors.full_messages.join).to include("append_only")
  end
end
