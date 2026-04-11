module Dental
  module SupplyCosting
    class RetryUsage < BaseUseCase
      def call(usage_record:, actor_id: nil)
        usage_record.mark_pending_for_retry!

        DeductUsage.call(usage_record: usage_record, actor_id: actor_id)
      end
    end
  end
end
