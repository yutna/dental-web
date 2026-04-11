module Dental
  module SupplyCosting
    class ReceiveRequisition < BaseUseCase
      def call(requisition:, receiver_id:)
        movements = []

        ActiveRecord::Base.transaction do
          requisition.receive!(receiver_id: receiver_id)

          requisition.line_items.each do |line_item|
            result = PostStockMovement.call(
              item_type: line_item.item_type,
              item_code: line_item.item_code,
              direction: "in",
              quantity: line_item.quantity,
              unit: line_item.unit,
              source: "requisition",
              reference_type: "requisition",
              reference_id: "#{requisition.requisition_id}:#{line_item.id}",
              actor_id: receiver_id,
              note: "Stock-in from requisition #{requisition.requisition_id} item #{line_item.item_code}"
            )
            movements << result[:movement]
          end
        end

        { requisition: requisition, movements: movements }
      end
    end
  end
end
