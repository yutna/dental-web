module Dental
  module Supply
    class DispenseRequisition < BaseUseCase
      def call(requisition:, actor_id:, dispense_number:)
        Dental::SupplyCosting::TransitionRequisition.call(
          requisition: requisition,
          action: "dispense",
          actor_id: actor_id,
          params: { dispense_number: dispense_number }
        )
      end
    end
  end
end
