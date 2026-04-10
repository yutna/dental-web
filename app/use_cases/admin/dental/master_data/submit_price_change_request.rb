module Admin
  module Dental
    module MasterData
      class SubmitPriceChangeRequest < ::BaseUseCase
        def call(item:, requested_by_id:, attributes:)
          DentalMasterDataChangeRequest.create!(
            resource_type: item.class.name,
            resource_id: item.id,
            change_type: "price_update",
            payload_json: attributes.to_json,
            status: "pending",
            requested_by_id: requested_by_id
          )
        end
      end
    end
  end
end
