module Dental
  module Workflow
    class AppendTimelineEntry < Dental::BaseUseCase
      def call(visit_id:, from_stage:, to_stage:, actor_id:, event_type: "stage_transition", metadata: {})
        DentalWorkflowTimelineEntry.create!(
          visit_id: visit_id,
          from_stage: from_stage,
          to_stage: to_stage,
          actor_id: actor_id,
          event_type: event_type,
          metadata_json: metadata.to_json,
          created_at: Time.current
        )
      end
    end
  end
end
