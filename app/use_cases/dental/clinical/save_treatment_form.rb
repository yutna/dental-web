module Dental
  module Clinical
    class SaveTreatmentForm < BaseUseCase
      def call(visit_id:, patient_hn:, actor_id:, payload:, posted_at: Time.current)
        procedures = normalize_procedures(payload)
        validate_procedures!(procedures)

        post = nil

        ApplicationRecord.transaction do
          post = DentalClinicalPost.create!(
            visit_id: visit_id,
            patient_hn: patient_hn,
            form_type: "treatment",
            stage: "in-treatment",
            posted_by_id: actor_id,
            posted_at: posted_at,
            payload_json: { "procedures" => procedures }.to_json
          )

          procedures.each do |procedure|
            DentalClinicalProcedureRecord.create!(
              clinical_post: post,
              visit_id: visit_id,
              patient_hn: patient_hn,
              procedure_item_code: procedure.fetch("procedure_item_code"),
              tooth_code: procedure["tooth_code"],
              surface_codes_json: Array(procedure["surface_codes"]).to_json,
              quantity: procedure.fetch("quantity", 1),
              note: procedure["note"],
              occurred_at: posted_at
            )
          end
        end

        {
          post_id: post.id,
          visit_id: visit_id,
          patient_hn: patient_hn,
          posted_at: post.posted_at,
          payload: post.payload,
          projection_count: procedures.size
        }
      end

      private

      def normalize_procedures(payload)
        payload_hash = payload.is_a?(Hash) ? payload.deep_stringify_keys : {}
        Array(payload_hash["procedures"]).map(&:deep_stringify_keys)
      end

      def validate_procedures!(procedures)
        if procedures.empty?
          raise_validation!(line: 0, field: "procedures", message: "At least one procedure is required")
        end

        procedures.each_with_index do |line, index|
          raise_validation!(line: index + 1, field: "procedure_item_code", message: "Procedure item is required") if line["procedure_item_code"].blank?
          raise_validation!(line: index + 1, field: "tooth_code", message: "Tooth is required") if line["tooth_code"].blank?
          raise_validation!(line: index + 1, field: "surface_codes", message: "At least one tooth surface is required") if Array(line["surface_codes"]).empty?
        end
      end

      def raise_validation!(line:, field:, message:)
        raise Dental::Errors::ValidationError.new(
          message: message,
          details: {
            form_type: "treatment",
            line: line,
            field: field
          }
        )
      end
    end
  end
end
