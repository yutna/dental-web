module Backend
  module Errors
    class AuthenticationError     < StandardError; end
    class UnexpectedResponseError < StandardError; end
    class ContractMismatchError   < StandardError; end
    class ValidationError         < StandardError; end
    class ServiceUnavailableError < StandardError; end
    class RetryExhaustedError     < StandardError; end
    class CircuitOpenError        < StandardError; end
  end
end
