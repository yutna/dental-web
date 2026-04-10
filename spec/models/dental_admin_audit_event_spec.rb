require "rails_helper"

RSpec.describe DentalAdminAuditEvent, type: :model do
  it "is append-only and cannot be updated" do
    event = create(:dental_admin_audit_event)

    expect(event.update(action: "procedure_item.created")).to be(false)
    expect(event.errors.full_messages.join).to include("append_only")
  end

  it "is append-only and cannot be destroyed" do
    event = create(:dental_admin_audit_event)

    expect(event.destroy).to be(false)
    expect(event.errors.full_messages.join).to include("append_only")
  end
end
