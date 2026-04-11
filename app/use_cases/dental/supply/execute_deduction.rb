module Dental
  module Supply
    class ExecuteDeduction < BaseUseCase
      def call(...)
        Dental::SupplyCosting::DeductUsage.call(...)
      end
    end
  end
end
