module Dental
  module Clinical
    class ChartFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        @visit_id = params[:visit_id]
        @result = Dental::Clinical::ChartFormQuery.call(visit_id: params[:visit_id])
        @queue_entry = DentalQueueEntry.find_by(visit_id: @visit_id)
        @snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: @visit_id)

        respond_to do |format|
          format.html
          format.json { render json: @result }
        end
      end

      def update
        authorize([ :dental, :clinical ], :write?)

        result = Dental::Clinical::SaveChartForm.call(
          visit_id: params[:visit_id],
          patient_hn: chart_params[:patient_hn].presence || "UNKNOWN-HN",
          actor_id: current_principal.id,
          payload: chart_payload
        )

        respond_to do |format|
          format.html do
            flash[:notice] = t("dental.clinical.chart.saved")
            redirect_to dental_clinical_chart_form_path(visit_id: params[:visit_id])
          end
          format.json { render json: result }
        end
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
