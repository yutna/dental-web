module Api
  module V1
    class ScreeningFormSerializer < ::BaseSerializer
      class << self
        def serialize(post)
          payload = post.payload
          payload.merge(
            "vitals" => payload.fetch("vitals", {}),
            "symptoms" => Array(payload["symptoms"])
          )
        end
      end
    end
  end
end
