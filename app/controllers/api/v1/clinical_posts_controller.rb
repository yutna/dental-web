module Api
  module V1
    class ClinicalPostsController < BaseController
      def index
        authorize([ :dental, :clinical ], :read?)

        posts = DentalClinicalPost.where(visit_id: params[:visit_id]).active.chronological
        posts = posts.where(form_type: params[:form_type]) if params[:form_type].present?
        total = posts.count
        records = posts.offset((page_number - 1) * per_page).limit(per_page)

        render_collection(records, ClinicalPostSerializer, total: total)
      end

      def create
        authorize([ :dental, :clinical ], :write?)

        post = DentalClinicalPost.new(
          visit_id: params[:visit_id],
          patient_hn: clinical_post_params[:patient_hn],
          form_type: clinical_post_params[:form_type],
          payload_json: (clinical_post_params[:payload] || {}).to_json,
          posted_by_id: current_principal.id,
          posted_at: Time.current
        )

        if post.save
          render_resource(post, ClinicalPostSerializer, status: :created)
        else
          render_validation_error(post)
        end
      end

      private

      def clinical_post_params
        params.permit(:patient_hn, :form_type, payload: {})
      end
    end
  end
end
