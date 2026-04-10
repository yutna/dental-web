module Dental
  module Enums
    class PaymentStatus < Dental::EnumValue
      def self.allowed_values
        %w[pending paid not-required].freeze
      end
    end
  end
end
