module Dental
  module SupplyCosting
    class BuildInvoice < BaseUseCase
      def call(visit_id:, patient_name: nil, eligibility_code: nil, line_items:, actor_id: nil)
        invoice_id = generate_invoice_id

        invoice = nil
        ActiveRecord::Base.transaction do
          invoice = DentalInvoice.create!(
            invoice_id: invoice_id,
            visit_id: visit_id,
            patient_name: patient_name,
            eligibility_code: eligibility_code,
            payment_status: "pending",
            actor_id: actor_id,
            total_amount: 0,
            copay_amount: 0
          )

          line_items.each do |item|
            amount = (item[:quantity].to_d * item[:unit_price].to_d).round(2)

            invoice.line_items.create!(
              item_type: item[:item_type],
              item_code: item[:item_code],
              item_name: item[:item_name],
              quantity: item[:quantity],
              unit: item[:unit],
              unit_price: item[:unit_price],
              amount: amount,
              price_source: item[:price_source],
              copay_amount: item[:copay_amount],
              copay_percent: item[:copay_percent]
            )
          end

          invoice.recalculate_totals!
        end

        { invoice: invoice }
      end

      private

      def generate_invoice_id
        year = Time.current.year
        seq = SecureRandom.hex(4).upcase
        "INV-#{year}-#{seq}"
      end
    end
  end
end
