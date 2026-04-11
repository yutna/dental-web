module Dental
  class PrintPolicy < BasePolicy
    BLOCKED_STAGES = %w[registered cancelled].freeze

    def show?
      return false unless user.allowed?("dental:print:read")

      stage = extract_stage
      return true if stage.blank?

      !BLOCKED_STAGES.include?(stage)
    end

    private

    def extract_stage
      return record.stage.to_s if record.respond_to?(:stage)
      return record[:stage].to_s if record.is_a?(Hash) && record[:stage].present?

      nil
    end
  end
end
