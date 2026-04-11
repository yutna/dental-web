module Dental
  module SupplyCosting
    class UsageStateMachine
      TRANSITIONS = {
        "pending_deduct" => %w[deducted failed].freeze,
        "deducted" => [].freeze,
        "failed" => %w[pending_deduct deducted].freeze
      }.freeze

      def self.allowed_transitions(from_status)
        normalized = Dental::Enums::UsageStatus.new(from_status).value
        TRANSITIONS.fetch(normalized, [])
      rescue ArgumentError
        []
      end

      def self.valid_transition?(from_status:, to_status:)
        normalized_to = Dental::Enums::UsageStatus.new(to_status).value
        allowed_transitions(from_status).include?(normalized_to)
      rescue ArgumentError
        false
      end
    end
  end
end
