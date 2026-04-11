module Dental
  module Supply
    class RetryDeduction < BaseUseCase
      def call(...)
        Dental::SupplyCosting::RetryUsage.call(...)
      end
    end
  end
end
