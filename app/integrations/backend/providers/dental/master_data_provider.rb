module Backend
  module Providers
    module Dental
      class MasterDataProvider < BaseProvider
        def list_procedures(filters: {})
          _filters = filters
          not_implemented!("list_procedures")
        end

        def list_medications(filters: {})
          _filters = filters
          not_implemented!("list_medications")
        end

        def list_supplies(filters: {})
          _filters = filters
          not_implemented!("list_supplies")
        end
      end
    end
  end
end
