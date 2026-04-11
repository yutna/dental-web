module Dental
  module SupplyCosting
    class SyncPayment < BaseUseCase
      # TODO (P05-DL-001): confirm callback/webhook authentication mechanism for payment sync endpoint.
      SIGNATURE_ALGORITHM = "SHA256"

      def call(invoice_id:, payment_status:, signature:, shared_secret:, paid_at: nil, idempotency_key: nil)
        verify_signature!(invoice_id: invoice_id, payment_status: payment_status, signature: signature, shared_secret: shared_secret)

        invoice = find_invoice!(invoice_id)

        return { invoice: invoice, changed: false } if invoice.paid?

        return { invoice: invoice, changed: false } unless payment_status == "paid"

        invoice.mark_paid!(paid_at: paid_at || Time.current)

        { invoice: invoice, changed: true }
      end

      private

      def verify_signature!(invoice_id:, payment_status:, signature:, shared_secret:)
        expected = compute_signature(
          payload: "#{invoice_id}:#{payment_status}",
          secret: shared_secret
        )

        return if ActiveSupport::SecurityUtils.secure_compare(expected, signature.to_s)

        raise Dental::Errors::Forbidden.new(
          details: { message: "invalid payment callback signature" }
        )
      end

      def compute_signature(payload:, secret:)
        OpenSSL::HMAC.hexdigest(SIGNATURE_ALGORITHM, secret, payload)
      end

      def find_invoice!(invoice_id)
        invoice = DentalInvoice.find_by(invoice_id: invoice_id)

        raise Dental::Errors::NotFound.new(
          details: { invoice_id: invoice_id }
        ) unless invoice

        invoice
      end
    end
  end
end
