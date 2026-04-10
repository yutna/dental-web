module Dental
  module Workflow
    class PaymentBridgeHook < BaseUseCase
      HOOK_MAP = {
        "waiting-payment" => "send_to_cashier",
        "referred-out" => "refer_out",
        "cancelled" => "cancel_visit"
      }.freeze

      def call(visit_id:, from_stage:, to_stage:, actor_id:, metadata: {})
        hook_type = resolve_hook_type(from_stage: from_stage, to_stage: to_stage)
        return { created: false, event: nil } if hook_type.nil?

        event = DentalPaymentBridgeEvent.create!(
          visit_id: visit_id,
          hook_type: hook_type,
          from_stage: from_stage,
          to_stage: to_stage,
          actor_id: actor_id,
          status: "pending",
          payload_json: {
            metadata: metadata,
            emitted_at: Time.current.iso8601
          }.to_json
        )

        {
          created: true,
          event: event
        }
      end

      private

      def resolve_hook_type(from_stage:, to_stage:)
        return "complete_no_charge" if from_stage == "in-treatment" && to_stage == "completed"

        HOOK_MAP[to_stage]
      end
    end
  end
end
