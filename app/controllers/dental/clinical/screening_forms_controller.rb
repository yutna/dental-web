module Dental
  module Clinical
    class ScreeningFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        result = Dental::Clinical::ScreeningFormQuery.call(visit_id: params[:visit_id])
        render json: result
      end

      def update
        authorize([ :dental, :clinical ], :write?)

        result = Dental::Clinical::SaveScreeningForm.call(
          visit_id: params[:visit_id],
          patient_hn: screening_params[:patient_hn].presence || "UNKNOWN-HN",
          actor_id: current_principal.id,
          payload: screening_payload
        )

        render json: result, status: :ok
      end

      private

      def screening_params
        params.permit(:patient_hn, vitals: [ :blood_pressure, :pulse, :weight, :temperature ], symptoms: [])
      end

      def screening_payload
        {
          "vitals" => screening_params.fetch(:vitals, {}).to_h,
          "symptoms" => Array(screening_params[:symptoms])
        }
      end
    end
  end
end
