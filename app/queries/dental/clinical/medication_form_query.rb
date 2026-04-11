module Dental
  module Clinical
    class MedicationFormQuery < BaseQuery
      def call(visit_id:)
        post = DentalClinicalPost.active
                                 .where(visit_id: visit_id, form_type: "medication")
                                 .order(posted_at: :desc, id: :desc)
                                 .first

        {
          visit_id: visit_id,
          form_type: "medication",
          exists: post.present?,
          posted_at: post&.posted_at,
          payload: post&.payload || {}
        }
      end
    end
  end
end
