module Dental
  module Clinical
    class SaveMedicationForm < BaseUseCase
      def call(visit_id:, patient_hn:, actor_id:, payload:, posted_at: Time.current)
        medications, confirm_high_alert = normalize_payload(payload)
        validate_medications!(medications, confirm_high_alert: confirm_high_alert)

        post = DentalClinicalPost.create!(
          visit_id: visit_id,
          patient_hn: patient_hn,
          form_type: "medication",
          stage: "in-treatment",
          posted_by_id: actor_id,
          posted_at: posted_at,
          payload_json: {
            "medications" => medications,
            "confirm_high_alert" => confirm_high_alert
          }.to_json
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

      def normalize_payload(payload)
        payload_hash = payload.is_a?(Hash) ? payload.deep_stringify_keys : {}
        medications = Array(payload_hash["medications"]).map(&:deep_stringify_keys)
        confirm_high_alert = ActiveModel::Type::Boolean.new.cast(payload_hash["confirm_high_alert"])
        [ medications, confirm_high_alert ]
      end

      def validate_medications!(medications, confirm_high_alert:)
        if medications.empty?
          raise_validation!(field: "medications", message: "At least one medication is required")
        end

        high_alert_codes = medications.filter_map do |line|
          code = line["medication_code"].to_s
          raise_validation!(field: "medication_code", message: "Medication code is required") if code.blank?
          raise_validation!(field: "quantity", message: "Quantity must be greater than zero") if line["quantity"].to_f <= 0

          profile = DentalMedicationProfile.find_by(code: code)
          profile&.category == "high_alert" ? code : nil
        end

        return if high_alert_codes.empty? || confirm_high_alert

        raise Dental::Errors::ValidationError.new(
          message: "High-alert medication requires confirmation",
          details: {
            form_type: "medication",
            requires_confirmation: true,
            high_alert_codes: high_alert_codes
          }
        )
      end

      def raise_validation!(field:, message:)
        raise Dental::Errors::ValidationError.new(
          message: message,
          details: {
            form_type: "medication",
            field: field
          }
        )
      end
    end
  end
end
