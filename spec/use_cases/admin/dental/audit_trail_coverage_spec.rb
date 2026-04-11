require "rails_helper"

RSpec.describe "Audit trail coverage" do
  let(:audit_logger) { Admin::Dental::AuditLogger.new }
  let(:actor_id) { "test-actor-1" }

  # -----------------------------------------------------------------------
  # Event type categories
  # -----------------------------------------------------------------------
  describe "DentalAdminAuditEvent event types" do
    it "defines all required event type categories" do
      expected = %w[workflow clinical stock requisition billing print admin]
      expect(DentalAdminAuditEvent::EVENT_TYPES).to match_array(expected)
    end

    it "defaults to admin event_type" do
      event = DentalAdminAuditEvent.create!(
        actor_id: actor_id,
        action: "test_action",
        resource_type: "TestResource",
        metadata_json: "{}",
        created_at: Time.current
      )
      expect(event.event_type).to eq("admin")
    end

    it "validates event_type against allowed values" do
      event = DentalAdminAuditEvent.new(
        actor_id: actor_id,
        action: "test",
        resource_type: "TestResource",
        metadata_json: "{}",
        event_type: "invalid_type"
      )
      expect(event).not_to be_valid
      expect(event.errors[:event_type]).to be_present
    end
  end

  # -----------------------------------------------------------------------
  # AuditLogger event_type support
  # -----------------------------------------------------------------------
  describe Admin::Dental::AuditLogger do
    it "logs workflow transition events" do
      event = audit_logger.call(
        actor_id: actor_id,
        action: "transition",
        resource: DentalQueueEntry,
        event_type: "workflow",
        metadata: { from_stage: "checked-in", to_stage: "screening" }
      )

      expect(event.event_type).to eq("workflow")
      expect(event.action).to eq("transition")
      expect(event.metadata).to include("from_stage" => "checked-in")
    end

    it "logs clinical save events" do
      event = audit_logger.call(
        actor_id: actor_id,
        action: "save_screening",
        resource: DentalClinicalPost,
        event_type: "clinical",
        metadata: { visit_id: "VISIT-001" }
      )

      expect(event.event_type).to eq("clinical")
      expect(event.action).to eq("save_screening")
    end

    it "logs stock movement events" do
      event = audit_logger.call(
        actor_id: actor_id,
        action: "deduct_usage",
        resource: DentalStockMovement,
        event_type: "stock",
        metadata: { item_code: "SUP-001", quantity: 5 }
      )

      expect(event.event_type).to eq("stock")
    end

    it "logs requisition change events" do
      event = audit_logger.call(
        actor_id: actor_id,
        action: "approve",
        resource: DentalRequisition,
        event_type: "requisition",
        metadata: { requisition_id: "REQ-001" }
      )

      expect(event.event_type).to eq("requisition")
    end

    it "logs billing events" do
      event = audit_logger.call(
        actor_id: actor_id,
        action: "sync_billing",
        resource: DentalInvoice,
        event_type: "billing",
        metadata: { invoice_count: 3 }
      )

      expect(event.event_type).to eq("billing")
    end

    it "logs print events" do
      event = audit_logger.call(
        actor_id: actor_id,
        action: "print_treatment_summary",
        resource: DentalClinicalPost,
        event_type: "print",
        metadata: { visit_id: "VISIT-001", format: "pdf" }
      )

      expect(event.event_type).to eq("print")
    end

    it "defaults to admin event_type when unspecified" do
      event = audit_logger.call(
        actor_id: actor_id,
        action: "create",
        resource: ClinicService
      )

      expect(event.event_type).to eq("admin")
    end
  end

  # -----------------------------------------------------------------------
  # Scoping and filtering
  # -----------------------------------------------------------------------
  describe "by_event_type scope" do
    before do
      DentalAdminAuditEvent.delete_all
      audit_logger.call(actor_id: actor_id, action: "a1", resource: DentalQueueEntry, event_type: "workflow")
      audit_logger.call(actor_id: actor_id, action: "a2", resource: DentalClinicalPost, event_type: "clinical")
      audit_logger.call(actor_id: actor_id, action: "a3", resource: ClinicService, event_type: "admin")
      audit_logger.call(actor_id: actor_id, action: "a4", resource: DentalRequisition, event_type: "requisition")
    end

    it "filters by specific event type" do
      results = DentalAdminAuditEvent.by_event_type("workflow")
      expect(results.count).to eq(1)
      expect(results.first.action).to eq("a1")
    end

    it "returns all when event_type is nil" do
      results = DentalAdminAuditEvent.by_event_type(nil)
      expect(results.count).to eq(4)
    end

    it "returns all when event_type is blank" do
      results = DentalAdminAuditEvent.by_event_type("")
      expect(results.count).to eq(4)
    end
  end

  # -----------------------------------------------------------------------
  # Query integration
  # -----------------------------------------------------------------------
  describe "AuditEventsQuery with event_type filter" do
    before do
      DentalAdminAuditEvent.delete_all
      audit_logger.call(actor_id: actor_id, action: "t1", resource: DentalQueueEntry, event_type: "workflow")
      audit_logger.call(actor_id: actor_id, action: "t2", resource: DentalClinicalPost, event_type: "clinical")
      audit_logger.call(actor_id: actor_id, action: "t3", resource: ClinicService, event_type: "admin")
    end

    it "filters audit events by event_type" do
      results = Dental::Admin::AuditEventsQuery.call(filters: { event_type: "clinical" })
      expect(results.count).to eq(1)
      expect(results.first.action).to eq("t2")
    end

    it "returns all events when event_type filter is empty" do
      results = Dental::Admin::AuditEventsQuery.call(filters: {})
      expect(results.count).to eq(3)
    end
  end

  # -----------------------------------------------------------------------
  # Append-only integrity
  # -----------------------------------------------------------------------
  describe "audit event immutability" do
    it "prevents updates to audit events" do
      event = audit_logger.call(
        actor_id: actor_id,
        action: "immutable_test",
        resource: ClinicService,
        event_type: "admin"
      )

      event.action = "hacked"
      expect(event.save).to be false
      expect(event.errors[:base]).to include("append_only")
    end

    it "prevents deletion of audit events" do
      event = audit_logger.call(
        actor_id: actor_id,
        action: "nodelete_test",
        resource: ClinicService,
        event_type: "admin"
      )

      expect(event.destroy).to be_falsey
    end
  end
end
