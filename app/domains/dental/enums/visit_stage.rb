module Dental
  module Enums
    class VisitStage < Dental::EnumValue
      def self.allowed_values
        %w[
          registered
          checked-in
          screening
          ready-for-treatment
          in-treatment
          waiting-payment
          completed
          referred-out
          cancelled
        ].freeze
      end
    end
  end
end
