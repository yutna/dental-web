module Dental
  module Clinical
    class SaveScreeningForm < BaseUseCase
      REQUIRED_VITAL_FIELDS = %w[blood_pressure pulse weight].freeze

      def call(visit_id:, patient_hn:, actor_id:, payload:, posted_at: Time.current)
        validate_payload!(payload)

        post = DentalClinicalPost.create!(
          visit_id: visit_id,
          patient_hn: patient_hn,
          form_type: "screening",
          stage: "screening",
          posted_by_id: actor_id,
          posted_at: posted_at,
          payload_json: payload.to_json
        )

        {
          post_id: post.id,
          visit_id: post.visit_id,
          patient_hn: post.patient_hn,
          posted_at: post.posted_at,
          payload: post.payload
        }
      end

      private

      def validate_payload!(payload)
        payload_hash = payload.is_a?(Hash) ? payload.deep_stringify_keys : {}
        vitals = payload_hash.fetch("vitals", {}).deep_stringify_keys
        missing_fields = REQUIRED_VITAL_FIELDS.select { |field| vitals[field].blank? }
        return if missing_fields.empty?

        raise Dental::Errors::ValidationError.new(
          message: "Please complete required screening fields",
          details: {
            form_type: "screening",
            missing_fields: missing_fields
          }
        )
      end
    end
  end
end
