module Dental
  class VisitsController < BaseController
    CHECK_IN_DEFAULT_SERVICE = "General Consultation".freeze

    def show
      authorize([ :dental, :visit ], :show?)

      if params[:id].to_s.casecmp("VISIT-NOT-FOUND").zero?
        raise Dental::Errors::NotFound.new(details: { visit_id: params[:id] })
      end

      snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: params[:id])

      render json: {
        visit_id: params[:id],
        current_stage: snapshot[:current_stage],
        lock_version: snapshot[:lock_version],
        last_updated_at: snapshot[:last_event_at]&.iso8601
      }
    end

    def transition
      authorize([ :dental, :visit ], :transition?)

      snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: params[:id])
      from_stage = params[:from_stage].presence || snapshot[:current_stage]
      to_stage = params[:to_stage].to_s

      validate_lock_version!(snapshot:, from_stage:, to_stage:)
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

      updated_snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: params[:id])

      render json: {
        visit_id: params[:id],
        transitioned: true,
        from_stage: from_stage,
        to_stage: to_stage,
        current_stage: updated_snapshot[:current_stage],
        lock_version: updated_snapshot[:lock_version],
        last_updated_at: updated_snapshot[:last_event_at]&.iso8601
      }
    end

    def check_in
      authorize([ :dental, :visit ], :check_in?)

      vn = params[:vn].to_s
      if vn.blank?
        raise Dental::Errors::GuardViolation.new(
          message: "No active visit found",
          details: {
            guard: "active_vn_required"
          }
        )
      end

      visit_id = params[:visit_id].presence || "VISIT-#{SecureRandom.hex(4).upcase}"
      starts_at = Time.current.strftime("%H:%M")

      result = Dental::Workflow::RegisterQueueEntry.call(
        visit_id: visit_id,
        patient_name: params[:patient_name].presence || "Unknown Patient",
        mrn: params[:mrn].presence || "UNKNOWN-MRN",
        service: params[:service].presence || CHECK_IN_DEFAULT_SERVICE,
        starts_at: starts_at,
        status: "scheduled",
        source: "walk_in",
        actor_id: current_principal.id,
        metadata: {
          vn: vn,
          queue_origin: "check_in"
        }
      )

      Dental::Workflow::AppendTimelineEntry.call(
        visit_id: visit_id,
        from_stage: "registered",
        to_stage: "checked-in",
        actor_id: current_principal.id,
        metadata: {
          transition_source: "check_in"
        }
      )

      queue_position = DentalQueueEntry.where(created_at: ..result[:entry].created_at).count

      render json: {
        visit_id: visit_id,
        current_stage: "checked-in",
        queue_position: queue_position,
        created: result[:created]
      }, status: :created
    end

    def sync_appointments
      authorize([ :dental, :visit ], :sync_appointments?)

      result = Dental::Workflow::SyncAppointmentsToQueue.call(actor_id: current_principal.id)

      render json: {
        synced: true,
        created_registered_visits: result[:created_count],
        skipped_duplicates: result[:skipped_count],
        errors: result[:errors],
        error_count: result[:error_count]
      }
    end

    private

    def validate_lock_version!(snapshot:, from_stage:, to_stage:)
      expected_lock_version = params[:lock_version]
      return if expected_lock_version.blank?
      return if expected_lock_version.to_i == snapshot[:lock_version]

      raise Dental::Errors::StageUpdateConflict.new(
        message: "This visit was updated by another user",
        details: {
          visit_id: params[:id],
          attempted_from_stage: from_stage,
          attempted_to_stage: to_stage,
          current_stage: snapshot[:current_stage],
          current_lock_version: snapshot[:lock_version],
          expected_lock_version: expected_lock_version.to_i,
          last_updated_at: snapshot[:last_event_at]&.iso8601,
          last_updated_by: snapshot[:last_actor_id]
        }
      )
    end

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
