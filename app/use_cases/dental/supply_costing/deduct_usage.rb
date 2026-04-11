module Dental
  module SupplyCosting
    class DeductUsage < BaseUseCase
      def call(usage_record:, actor_id: nil)
        raise Dental::Errors::InvalidTransition.new(
          details: { usage_id: usage_record.usage_id, current_status: usage_record.status, attempted: "deducted" }
        ) unless usage_record.pending_deduct?

        result = PostStockMovement.call(
          item_type: usage_record.item_type,
          item_code: usage_record.item_code,
          direction: "out",
          quantity: usage_record.requested_quantity,
          unit: usage_record.unit,
          source: "pharmacy",
          reference_type: "usage",
          reference_id: usage_record.usage_id,
          actor_id: actor_id,
          note: "Deduction for #{usage_record.item_name}"
        )

        usage_record.mark_deducted!(
          movement_ref: result[:movement].movement_ref,
          quantity: usage_record.requested_quantity
        )

        { usage_record: usage_record, movement: result[:movement], created: result[:created] }
      rescue Dental::Errors::InsufficientStock => e
        usage_record.mark_failed!(error_message: e.message)
        { usage_record: usage_record, movement: nil, created: false, error: e }
      end
    end
  end
end
