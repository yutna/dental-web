module Dental
  module Errors
    class BaseError < StandardError
      attr_reader :code, :details

      def initialize(message: self.class::DEFAULT_MESSAGE, details: {})
        super(message)
        @code = self.class::CODE
        @details = normalize_details(details)
      end

      def to_h
        {
          code: code,
          message: message,
          details: details
        }
      end

      private

      def normalize_details(value)
        return {} unless value.is_a?(Hash)

        value.each_with_object({}) do |(key, content), memo|
          memo[key.to_s] = content
        end
      end
    end

    class InvalidTransition < BaseError
      CODE = Dental::ErrorCode::INVALID_STAGE_TRANSITION
      DEFAULT_MESSAGE = "Invalid stage transition".freeze
    end

    class NotFound < BaseError
      CODE = Dental::ErrorCode::NOT_FOUND
      DEFAULT_MESSAGE = "Not found".freeze
    end

    class Forbidden < BaseError
      CODE = Dental::ErrorCode::FORBIDDEN
      DEFAULT_MESSAGE = "Forbidden".freeze
    end

    class GuardViolation < BaseError
      CODE = Dental::ErrorCode::STATE_GUARD_VIOLATION
      DEFAULT_MESSAGE = "State guard violation".freeze
    end

    class ValidationError < BaseError
      CODE = Dental::ErrorCode::VALIDATION_ERROR
      DEFAULT_MESSAGE = "Validation failed".freeze
    end

    class InsufficientStock < BaseError
      CODE = Dental::ErrorCode::INSUFFICIENT_STOCK
      DEFAULT_MESSAGE = "Insufficient stock".freeze
    end

    class StageUpdateConflict < BaseError
      CODE = Dental::ErrorCode::STALE_UPDATE_CONFLICT
      DEFAULT_MESSAGE = "Stage update conflict".freeze
    end

    class ContractMismatch < BaseError
      CODE = Dental::ErrorCode::CONTRACT_MISMATCH
      DEFAULT_MESSAGE = "Contract mismatch".freeze
    end

    class ExternalIntegrationUnavailable < BaseError
      CODE = Dental::ErrorCode::EXTERNAL_INTEGRATION_UNAVAILABLE
      DEFAULT_MESSAGE = "External integration unavailable".freeze
    end
  end
end
