module Api
  module V1
    class ClinicalPostSerializer < ::BaseSerializer
      class << self
        def serialize(post)
          {
            id: post.id,
            visit_id: post.visit_id,
            patient_hn: post.patient_hn,
            form_type: post.form_type,
            payload: post.payload,
            posted_by_id: post.posted_by_id,
            posted_at: post.posted_at&.iso8601,
            voided_at: post.voided_at&.iso8601,
            created_at: post.created_at&.iso8601,
            updated_at: post.updated_at&.iso8601
          }
        end
      end
    end
  end
end
