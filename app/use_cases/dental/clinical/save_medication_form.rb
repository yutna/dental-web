module Dental
  module Clinical
    class SaveMedicationForm < BaseUseCase
      def call(visit_id:, patient_hn:, actor_id:, payload:, posted_at: Time.current)
        medications, confirm_high_alert, allergies, override_reason = normalize_payload(payload)
        validate_medications!(
          medications,
          confirm_high_alert: confirm_high_alert,
          allergies: allergies,
          override_reason: override_reason
        )

        post = DentalClinicalPost.create!(
          visit_id: visit_id,
          patient_hn: patient_hn,
          form_type: "medication",
          stage: "in-treatment",
          posted_by_id: actor_id,
          posted_at: posted_at,
          payload_json: {
            "medications" => medications,
            "confirm_high_alert" => confirm_high_alert,
            "allergies" => allergies,
            "allergy_override_reason" => override_reason
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
        allergies = Array(payload_hash["allergies"]).map(&:deep_stringify_keys)
        confirm_high_alert = ActiveModel::Type::Boolean.new.cast(payload_hash["confirm_high_alert"])
        override_reason = payload_hash["allergy_override_reason"].to_s.strip
        [ medications, confirm_high_alert, allergies, override_reason ]
      end

      def validate_medications!(medications, confirm_high_alert:, allergies:, override_reason:)
        if medications.empty?
          raise_validation!(field: "medications", message: "At least one medication is required")
        end

        high_alert_codes = medications.filter_map do |line|
          code = line["medication_code"].to_s.upcase
          raise_validation!(field: "medication_code", message: "Medication code is required") if code.blank?
          raise_validation!(field: "quantity", message: "Quantity must be greater than zero") if line["quantity"].to_f <= 0

          profile = DentalMedicationProfile.find_by(code: code)
          profile&.category == "high_alert" ? code : nil
        end

        unless high_alert_codes.empty? || confirm_high_alert
          raise Dental::Errors::ValidationError.new(
            message: "High-alert medication requires confirmation",
            details: {
              form_type: "medication",
              requires_confirmation: true,
              high_alert_codes: high_alert_codes
            }
          )
        end

        detect_and_validate_allergy_conflicts!(
          medications,
          allergies: allergies,
          override_reason: override_reason
        )
      end

      def detect_and_validate_allergy_conflicts!(medications, allergies:, override_reason:)
        allergy_by_code = allergies.each_with_object({}) do |allergy, acc|
          code = allergy["medication_code"].to_s.upcase
          acc[code] = allergy if code.present?
        end

        conflicts = medications.filter_map do |line|
          medication_code = line["medication_code"].to_s.upcase
          allergy = allergy_by_code[medication_code]
          next nil if allergy.nil?

          {
            medication_code: medication_code,
            allergy_medication_code: medication_code,
            reaction: allergy["reaction"].to_s.presence
          }.compact
        end

        return if conflicts.empty?

        if override_reason.blank?
          raise Dental::Errors::ValidationError.new(
            message: "Medication conflicts with documented allergy",
            details: {
              form_type: "medication",
              requires_override: true,
              allergy_conflicts: conflicts
            }
          )
        end
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
