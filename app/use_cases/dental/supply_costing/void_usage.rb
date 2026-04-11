module Dental
  module SupplyCosting
    class VoidUsage < BaseUseCase
      def call(usage_record:, reason:, actor_id: nil)
        raise Dental::Errors::GuardViolation.new(
          details: { usage_id: usage_record.usage_id, message: "already voided" }
        ) if usage_record.voided?

        ActiveRecord::Base.transaction do
          compensating_movement = nil

          if usage_record.deducted? && usage_record.movement_ref.present?
            compensating_movement = post_compensating_movement(usage_record, actor_id)
          end

          usage_record.void!(reason: reason)

          { usage_record: usage_record, compensating_movement: compensating_movement }
        end
      end

      private

      def post_compensating_movement(usage_record, actor_id)
        result = PostStockMovement.call(
          item_type: usage_record.item_type,
          item_code: usage_record.item_code,
          direction: "in",
          quantity: usage_record.deducted_quantity,
          unit: usage_record.unit,
          source: "pharmacy",
          reference_type: "usage",
          reference_id: usage_record.usage_id,
          actor_id: actor_id,
          note: "Compensating return for voided usage #{usage_record.usage_id}"
        )
        result[:movement]
      end
    end
  end
end
