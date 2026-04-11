module Api
  module V1
    class MedicationFormSerializer < ::BaseSerializer
      class << self
        def serialize(post)
          payload = post.payload

          {
            "medications" => Array(payload["medications"]),
            "confirm_high_alert" => ActiveModel::Type::Boolean.new.cast(payload["confirm_high_alert"]),
            "allergies" => Array(payload["allergies"]),
            "allergy_override_reason" => payload["allergy_override_reason"]
          }.compact
        end
      end
    end
  end
end
