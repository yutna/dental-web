module Dental
  class VisitsController < BaseController
    def show
      render json: { visit_id: params[:id] }
    end

    def transition
      render json: { visit_id: params[:id], transitioned: false }
    end
  end
end
