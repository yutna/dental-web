module Dental
  module Clinical
    class MedicationFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        @visit_id = params[:visit_id]
        @result = Dental::Clinical::MedicationFormQuery.call(visit_id: params[:visit_id])
        @queue_entry = DentalQueueEntry.find_by(visit_id: @visit_id)
        @snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: @visit_id)

        respond_to do |format|
          format.html
          format.json { render json: @result }
        end
      end

      def update
        authorize([ :dental, :clinical ], :write?)

        result = Dental::Clinical::SaveMedicationForm.call(
          visit_id: params[:visit_id],
          patient_hn: medication_params[:patient_hn].presence || "UNKNOWN-HN",
          actor_id: current_principal.id,
          payload: medication_payload
        )

        respond_to do |format|
          format.html do
            flash[:notice] = t("dental.clinical.medication.saved")
            redirect_to dental_clinical_medication_form_path(visit_id: params[:visit_id])
          end
          format.json { render json: result }
        end
      end

      private

      def medication_params
        params.permit(
          :patient_hn,
          :confirm_high_alert,
          :allergy_override_reason,
          medications: [ :medication_code, :quantity, :note ],
          allergies: [ :medication_code, :reaction ]
        )
      end

      def medication_payload
        {
          "confirm_high_alert" => medication_params[:confirm_high_alert],
          "allergy_override_reason" => medication_params[:allergy_override_reason],
          "medications" => Array(medication_params[:medications]).map { |line| line.respond_to?(:to_h) ? line.to_h : line },
          "allergies" => Array(medication_params[:allergies]).map { |line| line.respond_to?(:to_h) ? line.to_h : line }
        }
      end
    end
  end
end
