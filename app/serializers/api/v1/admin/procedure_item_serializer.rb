module Api
  module V1
    module Admin
      class ProcedureItemSerializer < ::BaseSerializer
        class << self
          def serialize(item)
            {
              id: item.id,
              code: item.code,
              name: item.name,
              procedure_group_id: item.procedure_group_id,
              price_opd: item.price_opd,
              price_ipd: item.price_ipd,
              active: item.active,
              updated_at: item.updated_at&.iso8601
            }
          end
        end
      end
    end
  end
end
