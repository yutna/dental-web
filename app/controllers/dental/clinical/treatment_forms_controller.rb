module Dental
  module Clinical
    class TreatmentFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        @visit_id = params[:visit_id]
        @result = Dental::Clinical::TreatmentFormQuery.call(visit_id: params[:visit_id])
        @queue_entry = DentalQueueEntry.find_by(visit_id: @visit_id)
        @snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: @visit_id)

        respond_to do |format|
          format.html
          format.json { render json: @result }
        end
      end

      def update
        authorize([ :dental, :clinical ], :write?)

        result = Dental::Clinical::SaveTreatmentForm.call(
          visit_id: params[:visit_id],
          patient_hn: treatment_params[:patient_hn].presence || "UNKNOWN-HN",
          actor_id: current_principal.id,
          payload: treatment_payload
        )

        respond_to do |format|
          format.html do
            flash[:notice] = t("dental.clinical.treatment.saved")
            redirect_to dental_clinical_treatment_form_path(visit_id: params[:visit_id])
          end
          format.json { render json: result }
        end
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
