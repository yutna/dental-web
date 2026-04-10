module Dental
  module Enums
    class RequisitionStatus < Dental::EnumValue
      def self.allowed_values
        %w[pending approved dispensed received cancelled].freeze
      end
    end
  end
end
