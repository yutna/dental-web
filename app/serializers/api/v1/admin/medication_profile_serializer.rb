module Api
  module V1
    module Admin
      class MedicationProfileSerializer < ::BaseSerializer
        class << self
          def serialize(item)
            {
              id: item.id,
              code: item.code,
              name: item.name,
              category: item.category,
              active: item.active,
              updated_at: item.updated_at&.iso8601
            }
          end
        end
      end
    end
  end
end
