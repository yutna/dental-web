module Dental
  module Clinical
    class ScreeningFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        @visit_id = params[:visit_id]
        @result = Dental::Clinical::ScreeningFormQuery.call(visit_id: params[:visit_id])
        @queue_entry = DentalQueueEntry.find_by(visit_id: @visit_id)
        @snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: @visit_id)

        respond_to do |format|
          format.html
          format.json { render json: @result }
        end
      end

      def update
        authorize([ :dental, :clinical ], :write?)

        result = Dental::Clinical::SaveScreeningForm.call(
          visit_id: params[:visit_id],
          patient_hn: screening_params[:patient_hn].presence || "UNKNOWN-HN",
          actor_id: current_principal.id,
          payload: screening_payload
        )

        respond_to do |format|
          format.html do
            flash[:notice] = t("dental.clinical.screening.saved")
            if params[:commit] == "save_and_continue"
              redirect_to dental_clinical_workspace_path(visit_id: params[:visit_id], tab: "treatment")
            else
              redirect_to dental_clinical_screening_form_path(visit_id: params[:visit_id])
            end
          end
          format.json { render json: result, status: :ok }
        end
      end

      private

      def screening_params
        params.permit(:patient_hn, :allergy_notes, :preliminary_findings, :commit,
          vitals: [ :blood_pressure, :pulse, :weight, :temperature, :height ], symptoms: [])
      end

      def screening_payload
        {
          "vitals" => screening_params.fetch(:vitals, {}).to_h,
          "symptoms" => Array(screening_params[:symptoms]),
          "allergy_notes" => screening_params[:allergy_notes].to_s,
          "preliminary_findings" => screening_params[:preliminary_findings].to_s
        }
      end
    end
  end
end
