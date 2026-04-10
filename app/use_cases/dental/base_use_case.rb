module Dental
  class BaseUseCase < ::BaseUseCase
    private

    def success(payload: {})
      Backend::Providers::Dental::Result.success(payload: payload)
    end

    def failure(error_code:, error_message:, details: {})
      Backend::Providers::Dental::Result.failure(
        error_code: error_code,
        error_message: error_message,
        details: details
      )
    end
  end
end
