module Api
  module V1
    class RequisitionsController < BaseController
      def index
        authorize([ :dental, :requisition ], :index?)

        scope = DentalRequisition.includes(:line_items).order(created_at: :desc)
        total = scope.count
        records = scope.offset((page_number - 1) * per_page).limit(per_page)

        render_collection(records, RequisitionSerializer, total: total)
      end

      def show
        authorize([ :dental, :requisition ], :show?)

        requisition = DentalRequisition.includes(:line_items).find(params[:id])
        render_resource(requisition, RequisitionSerializer)
      end
    end
  end
end
