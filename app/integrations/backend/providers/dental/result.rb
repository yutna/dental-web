module Backend
  module Providers
    module Dental
      class Result
        attr_reader :payload, :error_code, :error_message, :details

        def self.success(payload: {})
          new(payload: payload, error_code: nil, error_message: nil, details: {})
        end

        def self.failure(error_code:, error_message:, details: {})
          new(
            payload: {},
            error_code: error_code,
            error_message: error_message,
            details: details
          )
        end

        def initialize(payload:, error_code:, error_message:, details: {})
          @payload = normalize_payload(payload)
          @error_code = normalize_error_code(error_code)
          @error_message = error_message&.to_s
          @details = normalize_details(details)

          validate_state!
        end

        def ok?
          error_code.nil?
        end

        def failure?
          !ok?
        end

        def to_h
          {
            payload: payload,
            error_code: error_code,
            error_message: error_message,
            details: details
          }
        end

        private

        def normalize_payload(value)
          return {} unless value.is_a?(Hash)

          value.deep_stringify_keys
        end

        def normalize_error_code(value)
          return nil if value.blank?

          value.to_s
        end

        def normalize_details(value)
          return {} unless value.is_a?(Hash)

          value.deep_stringify_keys
        end

        def validate_state!
          if error_code && !::Dental::ErrorCode::ALL.include?(error_code)
            raise ArgumentError, "Unknown dental error code: #{error_code}"
          end

          return if ok? && error_message.blank?

          return if failure? && error_message.present?

          if ok?
            raise ArgumentError, "Successful result cannot have error_message"
          end

          raise ArgumentError, "Failed result requires error_message"
        end
      end
    end
  end
end
