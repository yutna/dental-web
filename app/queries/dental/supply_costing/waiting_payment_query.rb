module Dental
  module SupplyCosting
    class WaitingPaymentQuery < BaseQuery
      def call(status: nil)
        scope = DentalInvoice.includes(:line_items).order(created_at: :desc)

        if status.present?
          scope = scope.where(payment_status: status)
        else
          scope = scope.where(payment_status: "pending")
        end

        scope
      end
    end
  end
end
