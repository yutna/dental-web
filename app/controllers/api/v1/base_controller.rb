module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_api_user!

      rescue_from Dental::Errors::BaseError, with: :render_dental_error
      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      private

      def authenticate_api_user!
        token = extract_bearer_token
        if token.blank?
          render_error("UNAUTHORIZED", "Bearer token required", status: :unauthorized)
          return
        end

        snapshot = Backend::Mappers::SessionSnapshotMapper.from_bearer(token)
        if snapshot.guest?
          render_error("UNAUTHORIZED", "Invalid or expired token", status: :unauthorized)
          return
        end

        Current.principal = snapshot.principal
      rescue Backend::Errors::UnexpectedResponseError => e
        render_error("UNAUTHORIZED", e.message, status: :unauthorized)
      end

      def extract_bearer_token
        header = request.headers["Authorization"].to_s
        header.match(/\ABearer\s+(.+)\z/i)&.captures&.first
      end

      def current_principal
        Current.principal || Security::Principal.guest
      end

      def pundit_user
        current_principal
      end

      # Pagination
      def page_number
        [ (params[:page].to_i), 1 ].max
      end

      def per_page
        value = params[:per_page].to_i
        value = 25 if value < 1
        [ value, 100 ].min
      end

      def pagination_meta(collection, total:)
        {
          page: page_number,
          per_page: per_page,
          total: total,
          total_pages: (total.to_f / per_page).ceil
        }
      end

      # Standard success responses
      def render_resource(resource, serializer_class, status: :ok)
        render json: { data: serializer_class.serialize(resource) }, status: status
      end

      def render_collection(records, serializer_class, total:)
        render json: {
          data: records.map { |r| serializer_class.serialize(r) },
          meta: pagination_meta(records, total: total)
        }
      end

      # Standard error responses
      def render_dental_error(error)
        status = http_status_for(error.code)
        render json: {
          error: { code: error.code, message: error.message, details: error.details }
        }, status: status
      end

      def render_forbidden(_exception = nil)
        render_error("FORBIDDEN", "You are not authorized to perform this action", status: :forbidden)
      end

      def render_not_found(_exception = nil)
        render_error("NOT_FOUND", "Resource not found", status: :not_found)
      end

      def render_validation_error(record)
        render json: {
          error: {
            code: "VALIDATION_ERROR",
            message: "Validation failed",
            details: record.errors.messages
          }
        }, status: :unprocessable_content
      end

      def render_error(code, message, status:, details: {})
        render json: { error: { code: code, message: message, details: details } }, status: status
      end

      def http_status_for(code)
        case code
        when Dental::ErrorCode::UNAUTHORIZED then :unauthorized
        when Dental::ErrorCode::FORBIDDEN then :forbidden
        when Dental::ErrorCode::NOT_FOUND then :not_found
        when Dental::ErrorCode::DUPLICATE_ENTRY, Dental::ErrorCode::STALE_UPDATE_CONFLICT then :conflict
        when Dental::ErrorCode::VALIDATION_ERROR, Dental::ErrorCode::INVALID_STAGE_TRANSITION,
             Dental::ErrorCode::STATE_GUARD_VIOLATION, Dental::ErrorCode::INSUFFICIENT_STOCK
          :unprocessable_content
        when Dental::ErrorCode::CONTRACT_MISMATCH, Dental::ErrorCode::EXTERNAL_INTEGRATION_UNAVAILABLE
          :service_unavailable
        else :internal_server_error
        end
      end
    end
  end
end
