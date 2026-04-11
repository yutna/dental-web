module Dental
  module Supply
    class RequisitionsController < Dental::BaseController
      def index
        authorize([ :dental, :requisition ], :index?)
        @requisitions = DentalRequisition.order(created_at: :desc)
      end

      def show
        authorize([ :dental, :requisition ], :show?)
        @requisition = DentalRequisition.find(params[:id])
      end
    end
  end
end
