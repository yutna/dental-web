module Api
  module V1
    class InvoiceSerializer < ::BaseSerializer
      class << self
        def serialize(invoice)
          {
            id: invoice.id,
            invoice_id: invoice.invoice_id,
            visit_id: invoice.visit_id,
            patient_name: invoice.patient_name,
            payment_status: invoice.payment_status,
            total_amount: invoice.total_amount,
            copay_amount: invoice.copay_amount,
            paid_at: invoice.paid_at&.iso8601,
            line_items: invoice.line_items.map do |line|
              {
                item_type: line.item_type,
                item_code: line.item_code,
                item_name: line.item_name,
                quantity: line.quantity,
                unit: line.unit,
                unit_price: line.unit_price,
                amount: line.amount
              }
            end
          }
        end
      end
    end
  end
end
