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

      render json: {
        visit_id: params[:id],
        transitioned: true,
        from_stage: from_stage,
        to_stage: to_stage
      }
    end
  end
end
