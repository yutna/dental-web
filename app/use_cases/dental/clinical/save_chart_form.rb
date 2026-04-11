module Dental
  module Clinical
    class SaveChartForm < BaseUseCase
      def call(visit_id:, patient_hn:, actor_id:, payload:, posted_at: Time.current)
        charts = normalize_payload(payload)
        validate_charts!(charts)

        post = nil
        DentalClinicalPost.transaction do
          post = DentalClinicalPost.create!(
            visit_id: visit_id,
            patient_hn: patient_hn,
            form_type: "dental_chart",
            stage: "in-treatment",
            posted_by_id: actor_id,
            posted_at: posted_at,
            payload_json: {
              "charts" => charts
            }.to_json
          )

          charts.each do |row|
            DentalClinicalChartRecord.create!(
              clinical_post_id: post.id,
              visit_id: visit_id,
              patient_hn: patient_hn,
              occurred_at: post.posted_at,
              tooth_code: row["tooth_code"],
              charting_code: row["charting_code"],
              surface_codes_json: Array(row["surface_codes"]).to_json,
              root_codes_json: Array(row["root_codes"]).to_json,
              piece_codes_json: Array(row["piece_codes"]).to_json,
              note: row["note"].to_s.presence
            )
          end
        end

        {
          post_id: post.id,
          visit_id: post.visit_id,
          patient_hn: post.patient_hn,
          posted_at: post.posted_at,
          projection_count: charts.size,
          payload: post.payload
        }
      end

      private

      def normalize_payload(payload)
        payload_hash = payload.is_a?(Hash) ? payload.deep_stringify_keys : {}
        Array(payload_hash["charts"]).map(&:deep_stringify_keys)
      end

      def validate_charts!(charts)
        if charts.empty?
          raise_validation!(field: "charts", message: "At least one chart row is required")
        end

        charts.each do |row|
          raise_validation!(field: "tooth_code", message: "Tooth code is required") if row["tooth_code"].to_s.blank?
          raise_validation!(field: "charting_code", message: "Charting code is required") if row["charting_code"].to_s.blank?

          has_anatomy = [ row["surface_codes"], row["root_codes"], row["piece_codes"] ].any? do |codes|
            Array(codes).any?(&:present?)
          end
          next if has_anatomy

          raise Dental::Errors::ValidationError.new(
            message: "Please select at least one surface, root, or piece",
            details: {
              form_type: "dental_chart",
              field: "anatomy_codes"
            }
          )
        end
      end

      def raise_validation!(field:, message:)
        raise Dental::Errors::ValidationError.new(
          message: message,
          details: {
            form_type: "dental_chart",
            field: field
          }
        )
      end
    end
  end
end
