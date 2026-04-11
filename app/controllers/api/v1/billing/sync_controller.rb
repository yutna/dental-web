module Api
  module V1
    module Billing
      class SyncController < ::Api::V1::BaseController
        def create
          authorize([ :dental, :billing ], :sync?)

          result = Dental::Billing::SyncPayment.call(
            invoice_id: sync_params[:invoice_id],
            payment_status: sync_params[:payment_status],
            signature: sync_params[:signature],
            shared_secret: sync_params[:shared_secret],
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
          params.permit(:invoice_id, :payment_status, :signature, :shared_secret, :paid_at)
        end
      end
    end
  end
end
