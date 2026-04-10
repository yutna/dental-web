module Dental
  module Enums
    class StockSource < Dental::EnumValue
      def self.allowed_values
        %w[pharmacy requisition adjustment].freeze
      end
    end
  end
end
