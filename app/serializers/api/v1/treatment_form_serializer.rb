module Api
  module V1
    class TreatmentFormSerializer < ::BaseSerializer
      class << self
        def serialize(post)
          payload = post.payload

          {
            "procedures" => Array(payload["procedures"]),
            "diagnoses" => Array(payload["diagnoses"]),
            "notes" => payload["notes"]
          }.compact
        end
      end
    end
  end
end
