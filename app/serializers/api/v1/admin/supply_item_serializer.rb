module Api
  module V1
    module Admin
      class SupplyItemSerializer < ::BaseSerializer
        class << self
          def serialize(item)
            {
              id: item.id,
              supply_category_id: item.supply_category_id,
              code: item.code,
              name: item.name,
              unit: item.unit,
              unit_price: item.unit_price,
              active: item.active,
              updated_at: item.updated_at&.iso8601
            }
          end
        end
      end
    end
  end
end
