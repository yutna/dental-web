module Api
  module V1
    class InvoicesController < BaseController
      def index
        authorize([ :dental, :billing ], :index?)

        scope = DentalInvoice.includes(:line_items).order(created_at: :desc)
        total = scope.count
        records = scope.offset((page_number - 1) * per_page).limit(per_page)

        render_collection(records, InvoiceSerializer, total: total)
      end

      def show
        authorize([ :dental, :billing ], :show?)

        invoice = DentalInvoice.includes(:line_items).find(params[:id])
        render_resource(invoice, InvoiceSerializer)
      end
    end
  end
end
