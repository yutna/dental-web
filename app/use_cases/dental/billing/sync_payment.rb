module Dental
  module Billing
    class SyncPayment < BaseUseCase
      def call(...)
        Dental::SupplyCosting::SyncPayment.call(...)
      end
    end
  end
end
