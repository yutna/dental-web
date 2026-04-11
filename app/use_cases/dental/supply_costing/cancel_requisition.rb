module Dental
  module SupplyCosting
    class CancelRequisition < BaseUseCase
      def call(requisition:, reason:, actor_id: nil)
        raise Dental::Errors::GuardViolation.new(
          details: {
            requisition_id: requisition.requisition_id,
            message: "cancel reason is required"
          }
        ) if reason.blank?

        requisition.cancel!(reason: reason, actor_id: actor_id)

        { requisition: requisition }
      end
    end
  end
end
