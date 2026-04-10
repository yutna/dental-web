module Dental
  module Clinical
    class ScreeningFormQuery < BaseQuery
      def call(visit_id:)
        post = DentalClinicalPost.active
                                 .where(visit_id: visit_id, form_type: "screening")
                                 .order(posted_at: :desc, id: :desc)
                                 .first

        {
          visit_id: visit_id,
          form_type: "screening",
          exists: post.present?,
          posted_at: post&.posted_at,
          payload: post&.payload || {}
        }
      end
    end
  end
end
