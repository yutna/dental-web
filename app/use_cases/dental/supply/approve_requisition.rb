module Dental
  module Supply
    class ApproveRequisition < BaseUseCase
      def call(requisition:, actor_id:)
        Dental::SupplyCosting::TransitionRequisition.call(
          requisition: requisition,
          action: "approve",
          actor_id: actor_id
        )
      end
    end
  end
end
