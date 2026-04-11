module Api
  module V1
    module Admin
      class MedicationProfilesController < ::Api::V1::BaseController
        def index
          authorize([ :admin, :dental, :master_data, DentalMedicationProfile ], :index?)

          scope = policy_scope([ :admin, :dental, :master_data, DentalMedicationProfile ])
          total = scope.count
          records = scope.offset((page_number - 1) * per_page).limit(per_page)

          render_collection(records, MedicationProfileSerializer, total: total)
        end
      end
    end
  end
end
