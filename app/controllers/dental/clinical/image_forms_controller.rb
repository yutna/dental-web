module Dental
  module Clinical
    class ImageFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        @visit_id = params[:visit_id]
        @result = Dental::Clinical::ImageFormQuery.call(visit_id: params[:visit_id])
        @queue_entry = DentalQueueEntry.find_by(visit_id: @visit_id)
        @snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: @visit_id)

        respond_to do |format|
          format.html
          format.json { render json: @result }
        end
      end

      def update
        authorize([ :dental, :clinical ], :write?)

        result = Dental::Clinical::SaveImageForm.call(
          visit_id: params[:visit_id],
          patient_hn: image_params[:patient_hn].presence || "UNKNOWN-HN",
          actor_id: current_principal.id,
          payload: image_payload
        )

        respond_to do |format|
          format.html do
            flash[:notice] = t("dental.clinical.images.saved")
            redirect_to dental_clinical_image_form_path(visit_id: params[:visit_id])
          end
          format.json { render json: result }
        end
      end

      private

      def image_params
        params.permit(:patient_hn, images: [ :image_type_code, :image_ref, :note ])
      end

      def image_payload
        {
          "images" => Array(image_params[:images]).map { |line| line.respond_to?(:to_h) ? line.to_h : line }
        }
      end
    end
  end
end
