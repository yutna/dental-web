module Dental
  module Clinical
    class ImageFormQuery < BaseQuery
      def call(visit_id:)
        post = DentalClinicalPost.active
                                 .where(visit_id: visit_id, form_type: "dental_image")
                                 .order(posted_at: :desc, id: :desc)
                                 .first

        {
          visit_id: visit_id,
          form_type: "dental_image",
          exists: post.present?,
          posted_at: post&.posted_at,
          payload: post&.payload || {}
        }
      end
    end
  end
end
