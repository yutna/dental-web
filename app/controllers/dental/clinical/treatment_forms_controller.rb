module Dental
  module Clinical
    class TreatmentFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        result = Dental::Clinical::TreatmentFormQuery.call(visit_id: params[:visit_id])
        render json: result
      end

      def update
        authorize([ :dental, :clinical ], :write?)

        result = Dental::Clinical::SaveTreatmentForm.call(
          visit_id: params[:visit_id],
          patient_hn: treatment_params[:patient_hn].presence || "UNKNOWN-HN",
          actor_id: current_principal.id,
          payload: treatment_payload
        )

        render json: result
      end

      private

      def treatment_params
        params.permit(:patient_hn, procedures: [ :procedure_item_code, :tooth_code, :quantity, :note, { surface_codes: [] } ])
      end

      def treatment_payload
        {
          "procedures" => Array(treatment_params[:procedures]).map { |line| line.respond_to?(:to_h) ? line.to_h : line }
        }
      end
    end
  end
end
