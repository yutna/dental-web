module Dental
  module Billing
    class WaitingController < Dental::BaseController
      def show
        authorize([ :dental, :billing ], :index?)

        @invoices = Dental::SupplyCosting::WaitingPaymentQuery.call

        respond_to do |format|
          format.html
          format.json do
            render json: {
              invoices: @invoices.map { |inv| invoice_payload(inv) },
              summary: build_summary(@invoices)
            }
          end
        end
      end

      def sync
        authorize([ :dental, :billing ], :sync?)

        invoice = DentalInvoice.find_by!(invoice_id: params[:invoice_id])

        # TODO (P05-DL-001): replace with actual cashier provider call
        # For now, this is a placeholder that exposes the sync action surface
        respond_to do |format|
          format.html do
            flash[:notice] = t("dental.billing.waiting.sync_requested")
            redirect_to dental_billing_waiting_path
          end
          format.json do
            render json: { invoice_id: invoice.invoice_id, sync_status: "requested" }
          end
        end
      rescue ActiveRecord::RecordNotFound
        raise Dental::Errors::NotFound.new(details: { invoice_id: params[:invoice_id] })
      end

      private

      def invoice_payload(invoice)
        {
          invoice_id: invoice.invoice_id,
          visit_id: invoice.visit_id,
          patient_name: invoice.patient_name,
          total_amount: invoice.total_amount.to_d.to_f,
          copay_amount: invoice.copay_amount.to_d.to_f,
          payment_status: invoice.payment_status,
          sent_at: invoice.sent_at&.iso8601,
          paid_at: invoice.paid_at&.iso8601,
          line_items_count: invoice.line_items.size
        }
      end

      def build_summary(invoices)
        {
          pending: invoices.count { |i| i.payment_status == "pending" },
          paid: invoices.count { |i| i.payment_status == "paid" },
          total: invoices.size
        }
      end
    end
  end
end
