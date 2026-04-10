module Dental
  module Enums
    class StockDirection < Dental::EnumValue
      def self.allowed_values
        %w[in out].freeze
      end
    end
  end
end
