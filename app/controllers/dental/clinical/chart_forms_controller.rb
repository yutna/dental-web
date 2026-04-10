module Dental
  module Clinical
    class ChartFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        result = Dental::Clinical::ChartFormQuery.call(visit_id: params[:visit_id])
        render json: result
      end

      def update
        authorize([ :dental, :clinical ], :write?)

        result = Dental::Clinical::SaveChartForm.call(
          visit_id: params[:visit_id],
          patient_hn: chart_params[:patient_hn].presence || "UNKNOWN-HN",
          actor_id: current_principal.id,
          payload: chart_payload
        )

        render json: result
      end

      private

      def chart_params
        params.permit(
          :patient_hn,
          charts: [ :tooth_code, :charting_code, :note, { surface_codes: [], root_codes: [], piece_codes: [] } ]
        )
      end

      def chart_payload
        {
          "charts" => Array(chart_params[:charts]).map { |line| line.respond_to?(:to_h) ? line.to_h : line }
        }
      end
    end
  end
end
