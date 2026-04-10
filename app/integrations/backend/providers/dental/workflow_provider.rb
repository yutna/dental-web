module Backend
  module Providers
    module Dental
      class WorkflowProvider < BaseProvider
        def find_visit(visit_id)
          _visit_id = visit_id
          not_implemented!("find_visit")
        end

        def transition_visit(visit_id:, to_stage:, metadata: {})
          _visit_id = visit_id
          _to_stage = to_stage
          _metadata = metadata
          not_implemented!("transition_visit")
        end
      end
    end
  end
end
