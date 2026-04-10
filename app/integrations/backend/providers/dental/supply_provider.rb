module Backend
  module Providers
    module Dental
      class SupplyProvider < BaseProvider
        def deduct_usage(usage_reference:, payload: {})
          _usage_reference = usage_reference
          _payload = payload
          not_implemented!("deduct_usage")
        end

        def create_requisition(payload: {})
          _payload = payload
          not_implemented!("create_requisition")
        end
      end
    end
  end
end
