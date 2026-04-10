require "rails_helper"

RSpec.describe Dental::Admin::AuditEventsQuery do
  it "filters audit events by actor and action" do
    create(:dental_admin_audit_event, actor_id: "actor-1", action: "procedure_item.updated")
    create(:dental_admin_audit_event, actor_id: "actor-2", action: "procedure_item.created")

    result = described_class.call(filters: { actor_id: "actor-1", action: "procedure_item.updated" })

    expect(result.size).to eq(1)
    expect(result.first.actor_id).to eq("actor-1")
    expect(result.first.action).to eq("procedure_item.updated")
  end
end
