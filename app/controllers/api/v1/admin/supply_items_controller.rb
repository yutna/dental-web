module Api
  module V1
    module Admin
      class SupplyItemsController < ::Api::V1::BaseController
        def index
          authorize([ :admin, :dental, :master_data, DentalSupplyItem ], :index?)

          scope = policy_scope([ :admin, :dental, :master_data, DentalSupplyItem ])
          total = scope.count
          records = scope.offset((page_number - 1) * per_page).limit(per_page)

          render_collection(records, SupplyItemSerializer, total: total)
        end
      end
    end
  end
end
