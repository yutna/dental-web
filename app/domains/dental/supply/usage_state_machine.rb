module Dental
  module Supply
    class UsageStateMachine
      class << self
        def allowed_transitions(from_status)
          Dental::SupplyCosting::UsageStateMachine.allowed_transitions(from_status)
        end

        def valid_transition?(from_status:, to_status:)
          Dental::SupplyCosting::UsageStateMachine.valid_transition?(from_status: from_status, to_status: to_status)
        end
      end
    end
  end
end
