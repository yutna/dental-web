module Api
  module V1
    module Billing
      class SyncController < ::Api::V1::BaseController
        def create
          authorize([ :dental, :billing ], :sync?)

          shared_secret = payment_sync_shared_secret

          result = Dental::Billing::SyncPayment.call(
            invoice_id: sync_params[:invoice_id],
            payment_status: sync_params[:payment_status],
            signature: sync_params[:signature],
            shared_secret: shared_secret,
            paid_at: sync_params[:paid_at].presence
          )

          render json: {
            data: {
              invoice_id: result[:invoice].invoice_id,
              payment_status: result[:invoice].payment_status,
              changed: result[:changed]
            }
          }
        end

        private

        def sync_params
          params.permit(:invoice_id, :payment_status, :signature, :paid_at)
        end

        def payment_sync_shared_secret
          secret = ENV["PAYMENT_SYNC_SHARED_SECRET"].to_s
          return secret if secret.present?

          raise Dental::Errors::ContractMismatch.new(
            message: "payment sync secret is not configured",
            details: { setting: "PAYMENT_SYNC_SHARED_SECRET" }
          )
        end
      end
    end
  end
end
