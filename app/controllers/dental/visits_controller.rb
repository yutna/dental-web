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

      to_stage = params[:to_stage].to_s
      allowed_targets = Dental::Enums::VisitStage.values - [ "registered" ]
      unless allowed_targets.include?(to_stage)
        raise Dental::Errors::InvalidTransition.new(
          details: { visit_id: params[:id], to_stage: to_stage }
        )
      end

      render json: { visit_id: params[:id], transitioned: true, to_stage: to_stage }
    end
  end
end
