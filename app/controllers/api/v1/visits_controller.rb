module Api
  module V1
    class VisitsController < BaseController
      def show
        authorize([ :dental, :visit ], :show?)

        entry = DentalQueueEntry.find_by!(visit_id: params[:id])
        timeline = DentalWorkflowTimelineEntry.for_visit(params[:id])

        render json: {
          data: VisitSerializer.serialize_with_timeline(entry, timeline)
        }
      end

      def transition
        authorize([ :dental, :visit ], :transition?)

        snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: params[:id])
        from_stage = params[:from_stage].presence || snapshot[:current_stage]
        to_stage = params[:to_stage].to_s

        unless Dental::Workflow::VisitStateMachine.valid_transition?(from_stage: from_stage, to_stage: to_stage)
          raise Dental::Errors::InvalidTransition.new(
            details: {
              visit_id: params[:id],
              from_stage: from_stage,
              to_stage: to_stage,
              allowed_transitions: Dental::Workflow::VisitStateMachine.allowed_transitions(from_stage)
            }
          )
        end

        ActiveRecord::Base.transaction do
          Dental::Workflow::AppendTimelineEntry.call(
            visit_id: params[:id],
            from_stage: from_stage,
            to_stage: to_stage,
            actor_id: current_principal.id,
            metadata: { transition_source: "api_v1" }
          )

          Dental::Workflow::PaymentBridgeHook.call(
            visit_id: params[:id],
            from_stage: from_stage,
            to_stage: to_stage,
            actor_id: current_principal.id,
            metadata: { transition_source: "api_v1" }
          )
        end

        updated_snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: params[:id])

        render json: {
          data: {
            visit_id: params[:id],
            from_stage: from_stage,
            to_stage: to_stage,
            current_stage: updated_snapshot[:current_stage],
            lock_version: updated_snapshot[:lock_version]
          }
        }
      end

      def check_in
        authorize([ :dental, :visit ], :check_in?)

        visit_id = params[:visit_id].presence || "VISIT-#{SecureRandom.hex(4).upcase}"
        starts_at = Time.current.strftime("%H:%M")

        result = nil
        ActiveRecord::Base.transaction do
          result = Dental::Workflow::RegisterQueueEntry.call(
            visit_id: visit_id,
            patient_name: params[:patient_name].presence || "Unknown Patient",
            mrn: params[:mrn].presence || "UNKNOWN-MRN",
            service: params[:service].presence || "General Consultation",
            starts_at: starts_at,
            status: "scheduled",
            source: "walk_in",
            actor_id: current_principal.id,
            metadata: { vn: params[:vn], queue_origin: "api_check_in" }
          )

          Dental::Workflow::AppendTimelineEntry.call(
            visit_id: visit_id,
            from_stage: "registered",
            to_stage: "checked-in",
            actor_id: current_principal.id,
            metadata: { transition_source: "api_check_in" }
          )
        end

        render json: { data: VisitSerializer.serialize(result[:entry]) }, status: :created
      end
    end
  end
end
