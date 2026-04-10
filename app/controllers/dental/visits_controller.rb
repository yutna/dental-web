module Dental
  class VisitsController < BaseController
    def show
      authorize([ :dental, :visit ], :show?)

      if params[:id].to_s.casecmp("VISIT-NOT-FOUND").zero?
        raise Dental::Errors::NotFound.new(details: { visit_id: params[:id] })
      end

      render json: { visit_id: params[:id] }
    end

    def transition
      authorize([ :dental, :visit ], :transition?)

      from_stage = params[:from_stage].presence || "registered"
      to_stage = params[:to_stage].to_s

      validate_transition_guards!(from_stage: from_stage, to_stage: to_stage)

      allowed_transitions = Dental::Workflow::VisitStateMachine.allowed_transitions(from_stage)
      unless Dental::Workflow::VisitStateMachine.valid_transition?(from_stage: from_stage, to_stage: to_stage)
        raise Dental::Errors::InvalidTransition.new(
          details: {
            visit_id: params[:id],
            from_stage: from_stage,
            to_stage: to_stage,
            allowed_transitions: allowed_transitions
          }
        )
      end

      Dental::Workflow::AppendTimelineEntry.call(
        visit_id: params[:id],
        from_stage: from_stage,
        to_stage: to_stage,
        actor_id: current_principal.id,
        metadata: {
          transition_source: "visits_controller"
        }
      )

      render json: {
        visit_id: params[:id],
        transitioned: true,
        from_stage: from_stage,
        to_stage: to_stage
      }
    end

    private

    def validate_transition_guards!(from_stage:, to_stage:)
      case [ from_stage, to_stage ]
      when [ "checked-in", "screening" ]
        validate_room_availability!(from_stage: from_stage, to_stage: to_stage)
      when [ "screening", "ready-for-treatment" ]
        validate_vitals_minimum!(from_stage: from_stage, to_stage: to_stage)
      when [ "ready-for-treatment", "in-treatment" ]
        validate_dentist_assignment!(from_stage: from_stage, to_stage: to_stage)
      end
    end

    def validate_room_availability!(from_stage:, to_stage:)
      return if ActiveModel::Type::Boolean.new.cast(params[:room_available])

      raise Dental::Errors::GuardViolation.new(
        message: "No examination room available",
        details: {
          visit_id: params[:id],
          from_stage: from_stage,
          to_stage: to_stage,
          guard: "room_availability"
        }
      )
    end

    def validate_vitals_minimum!(from_stage:, to_stage:)
      required_vitals = %w[blood_pressure pulse weight]
      provided_vitals = params.fetch(:vitals, {})
      provided_vitals = provided_vitals.to_unsafe_h if provided_vitals.respond_to?(:to_unsafe_h)
      provided_vitals = provided_vitals.to_h.stringify_keys
      missing_vitals = required_vitals.reject { |field| provided_vitals[field].present? }
      return if missing_vitals.empty?

      raise Dental::Errors::GuardViolation.new(
        message: "Please complete vital signs before continuing",
        details: {
          visit_id: params[:id],
          from_stage: from_stage,
          to_stage: to_stage,
          guard: "vitals_required",
          missing_vitals: missing_vitals
        }
      )
    end

    def validate_dentist_assignment!(from_stage:, to_stage:)
      return if params[:dentist_id].present?

      raise Dental::Errors::GuardViolation.new(
        message: "Please assign a dentist",
        details: {
          visit_id: params[:id],
          from_stage: from_stage,
          to_stage: to_stage,
          guard: "dentist_assignment"
        }
      )
    end
  end
end
