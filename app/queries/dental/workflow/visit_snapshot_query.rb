module Dental
  module Workflow
    class VisitSnapshotQuery < BaseQuery
      def call(visit_id:)
        timeline_entries = DentalWorkflowTimelineEntry.for_visit(visit_id).order(:id)
        latest_entry = timeline_entries.last

        {
          visit_id: visit_id,
          current_stage: latest_entry&.to_stage || "registered",
          lock_version: timeline_entries.size,
          last_event_at: latest_entry&.created_at,
          last_actor_id: latest_entry&.actor_id
        }
      end
    end
  end
end
