module Dental
  module Clinical
    class HistoryDrawersController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        @history = Dental::Clinical::CumulativeHistoryQuery.call(visit_id: params[:visit_id])

        respond_to do |format|
          format.json { render json: @history }
          format.html
        end
      end
    end
  end
end
