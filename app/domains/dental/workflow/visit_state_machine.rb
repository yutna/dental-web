module Dental
  module Workflow
    class VisitStateMachine
      TRANSITIONS = {
        "registered" => %w[checked-in cancelled].freeze,
        "checked-in" => %w[screening cancelled].freeze,
        "screening" => %w[ready-for-treatment cancelled].freeze,
        "ready-for-treatment" => %w[in-treatment cancelled].freeze,
        "in-treatment" => %w[waiting-payment completed referred-out].freeze,
        "waiting-payment" => %w[completed].freeze,
        "completed" => [].freeze,
        "referred-out" => [].freeze,
        "cancelled" => [].freeze
      }.freeze

      def self.allowed_transitions(from_stage)
        normalized_from = normalize_stage(from_stage)
        TRANSITIONS.fetch(normalized_from, [])
      rescue ArgumentError
        []
      end

      def self.valid_transition?(from_stage:, to_stage:)
        normalized_to = normalize_stage(to_stage)
        allowed_transitions(from_stage).include?(normalized_to)
      rescue ArgumentError
        false
      end

      def self.normalize_stage(stage)
        Dental::Enums::VisitStage.new(stage).value
      end

      private_class_method :normalize_stage
    end
  end
end
