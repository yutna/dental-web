module Dental
  module SupplyCosting
    class TransitionRequisition < BaseUseCase
      ACTIONS = %w[approve dispense receive cancel].freeze

      def call(requisition:, action:, actor_id:, params: {})
        raise Dental::Errors::ValidationError.new(
          details: { message: "unknown action: #{action}" }
        ) unless ACTIONS.include?(action)

        send(:"perform_#{action}", requisition, actor_id, params)

        { requisition: requisition }
      end

      private

      def perform_approve(requisition, actor_id, _params)
        requisition.approve!(approver_id: actor_id)
      end

      def perform_dispense(requisition, actor_id, params)
        requisition.dispense!(
          dispenser_id: actor_id,
          dispense_number: params[:dispense_number]
        )
      end

      def perform_receive(requisition, actor_id, _params)
        requisition.receive!(receiver_id: actor_id)
      end

      def perform_cancel(requisition, _actor_id, params)
        requisition.cancel!(reason: params[:reason])
      end
    end
  end
end
