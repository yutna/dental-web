module Dental
  class BaseController < ApplicationController
    before_action :require_signed_in!

    rescue_from Dental::Errors::BaseError, with: :render_dental_error
    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

    private

    def render_dental_error(error)
      status = http_status_for(error.code)

      respond_to do |format|
        format.html do
          flash[:alert] = error.message
          redirect_back fallback_location: workspace_path
        end
        format.json do
          render(
            json: {
              error: {
                code: error.code,
                message: error.message,
                details: error.details
              }
            },
            status: status
          )
        end
      end
    end

    def render_forbidden
      respond_to do |format|
        format.html do
          flash[:alert] = t("dental.errors.forbidden")
          redirect_back fallback_location: workspace_path
        end
        format.json do
          render_dental_error_json(Dental::Errors::Forbidden.new)
        end
      end
    end

    def render_dental_error_json(error)
      render(
        json: {
          error: {
            code: error.code,
            message: error.message,
            details: error.details
          }
        },
        status: http_status_for(error.code)
      )
    end

    def http_status_for(code)
      case code
      when Dental::ErrorCode::UNAUTHORIZED
        :unauthorized
      when Dental::ErrorCode::FORBIDDEN
        :forbidden
      when Dental::ErrorCode::NOT_FOUND
        :not_found
      when Dental::ErrorCode::DUPLICATE_ENTRY,
           Dental::ErrorCode::STALE_UPDATE_CONFLICT
        :conflict
      when Dental::ErrorCode::VALIDATION_ERROR,
           Dental::ErrorCode::INVALID_STAGE_TRANSITION,
           Dental::ErrorCode::STATE_GUARD_VIOLATION,
           Dental::ErrorCode::INSUFFICIENT_STOCK
        :unprocessable_content
      when Dental::ErrorCode::CONTRACT_MISMATCH,
           Dental::ErrorCode::EXTERNAL_INTEGRATION_UNAVAILABLE
        :service_unavailable
      else
        :internal_server_error
      end
    end
  end
end
