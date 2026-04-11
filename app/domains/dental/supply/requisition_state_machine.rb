module Dental
  module Supply
    class RequisitionStateMachine
      class << self
        def allowed_transitions(from_status)
          DentalRequisition::ALLOWED_TRANSITIONS.fetch(from_status.to_s, [])
        end

        def valid_transition?(from_status:, to_status:)
          allowed_transitions(from_status).include?(to_status.to_s)
        end
      end
    end
  end
end
