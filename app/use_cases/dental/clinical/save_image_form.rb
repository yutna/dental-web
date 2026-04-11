module Dental
  module Clinical
    class SaveImageForm < BaseUseCase
      def call(visit_id:, patient_hn:, actor_id:, payload:, posted_at: Time.current)
        images = normalize_payload(payload)
        validate_images!(images)

        post = nil
        DentalClinicalPost.transaction do
          post = DentalClinicalPost.create!(
            visit_id: visit_id,
            patient_hn: patient_hn,
            form_type: "dental_image",
            stage: "in-treatment",
            posted_by_id: actor_id,
            posted_at: posted_at,
            payload_json: {
              "images" => images
            }.to_json
          )

          images.each do |row|
            DentalClinicalImageRecord.create!(
              clinical_post_id: post.id,
              visit_id: visit_id,
              patient_hn: patient_hn,
              captured_at: post.posted_at,
              image_type_code: row["image_type_code"],
              image_ref: row["image_ref"],
              note: row["note"].to_s.presence
            )
          end
        end

        {
          post_id: post.id,
          visit_id: post.visit_id,
          patient_hn: post.patient_hn,
          posted_at: post.posted_at,
          projection_count: images.size,
          payload: post.payload
        }
      end

      private

      def normalize_payload(payload)
        payload_hash = payload.is_a?(Hash) ? payload.deep_stringify_keys : {}
        Array(payload_hash["images"]).map(&:deep_stringify_keys)
      end

      def validate_images!(images)
        if images.empty?
          raise_validation!(field: "images", message: "At least one image row is required")
        end

        images.each do |row|
          raise_validation!(field: "image_type_code", message: "Image type code is required") if row["image_type_code"].to_s.blank?
          raise_validation!(field: "image_ref", message: "Image reference is required") if row["image_ref"].to_s.blank?
        end
      end

      def raise_validation!(field:, message:)
        raise Dental::Errors::ValidationError.new(
          message: message,
          details: {
            form_type: "dental_image",
            field: field
          }
        )
      end
    end
  end
end
