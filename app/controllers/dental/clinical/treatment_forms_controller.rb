module Dental
  module Clinical
    class TreatmentFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        @visit_id = params[:visit_id]
        @result = Dental::Clinical::TreatmentFormQuery.call(visit_id: params[:visit_id])
        @queue_entry = DentalQueueEntry.find_by(visit_id: @visit_id)
        @snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: @visit_id)
        @procedure_items = DentalProcedureItem.active.order(:code).select(:id, :code, :name, :price_opd)

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
        params.permit(:patient_hn, :notes, procedures: [ :procedure_item_code, :tooth_code, :surface_codes, :quantity, :note, :price, :coverage, { surface_codes: [] } ])
      end

      def treatment_payload
        {
          "procedures" => Array(treatment_params[:procedures]).map { |line|
            h = line.respond_to?(:to_h) ? line.to_h : line
            h = h.deep_stringify_keys
            sc = h["surface_codes"]
            h["surface_codes"] = sc.is_a?(Array) ? sc.map(&:to_s).reject(&:blank?) : sc.to_s.split(",").map(&:strip).reject(&:blank?)
            h
          },
          "notes" => treatment_params[:notes].to_s
        }
      end
    end
  end
end
