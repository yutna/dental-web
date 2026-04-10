module Dental
  module Clinical
    class ImageFormsController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        result = Dental::Clinical::ImageFormQuery.call(visit_id: params[:visit_id])
        render json: result
      end

      def update
        authorize([ :dental, :clinical ], :write?)

        result = Dental::Clinical::SaveImageForm.call(
          visit_id: params[:visit_id],
          patient_hn: image_params[:patient_hn].presence || "UNKNOWN-HN",
          actor_id: current_principal.id,
          payload: image_payload
        )

        render json: result
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
