module Backend
  module Providers
    module Dental
      class ClinicalProvider < BaseProvider
        def save_screening(visit_id:, attributes: {})
          _visit_id = visit_id
          _attributes = attributes
          not_implemented!("save_screening")
        end

        def save_treatment(visit_id:, attributes: {})
          _visit_id = visit_id
          _attributes = attributes
          not_implemented!("save_treatment")
        end
      end
    end
  end
end
