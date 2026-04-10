module Dental
  module Enums
    class UsageStatus < Dental::EnumValue
      def self.allowed_values
        %w[pending_deduct deducted failed].freeze
      end
    end
  end
end
