module Dental
  module Billing
    class CreateInvoice < BaseUseCase
      def call(...)
        Dental::SupplyCosting::BuildInvoice.call(...)
      end
    end
  end
end
