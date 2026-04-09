module Backend
  module Errors
    class AuthenticationError < StandardError; end
    class UnexpectedResponseError < StandardError; end
    class ContractMismatchError < StandardError; end
  end
end
