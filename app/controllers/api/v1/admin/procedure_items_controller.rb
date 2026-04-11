module Api
  module V1
    module Admin
      class ProcedureItemsController < ::Api::V1::BaseController
        def index
          authorize([ :admin, :dental, :master_data, DentalProcedureItem ], :index?)

          scope = policy_scope([ :admin, :dental, :master_data, DentalProcedureItem ])
          total = scope.count
          records = scope.offset((page_number - 1) * per_page).limit(per_page)

          render_collection(records, ProcedureItemSerializer, total: total)
        end
      end
    end
  end
end
