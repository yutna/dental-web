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
            payload: serialized_payload(post),
            posted_by_id: post.posted_by_id,
            posted_at: post.posted_at&.iso8601,
            voided_at: post.voided_at&.iso8601,
            created_at: post.created_at&.iso8601,
            updated_at: post.updated_at&.iso8601
          }
        end

        private

        def serialized_payload(post)
          serializer_for(post.form_type).serialize(post)
        end

        def serializer_for(form_type)
          case form_type.to_s
          when "screening"
            ScreeningFormSerializer
          when "treatment"
            TreatmentFormSerializer
          when "medication"
            MedicationFormSerializer
          else
            PassthroughPayloadSerializer
          end
        end
      end

      class PassthroughPayloadSerializer < ::BaseSerializer
        class << self
          def serialize(post)
            post.payload
          end
        end
      end
    end
  end
end
