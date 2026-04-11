module Dental
  class RequisitionPolicy < BasePolicy
    def index?
      user.allowed?("dental:requisition:read")
    end

    def show?
      user.allowed?("dental:requisition:read")
    end

    def create?
      user.allowed?("dental:requisition:write")
    end

    def approve?
      user.allowed?("dental:requisition:approve")
    end

    def dispense?
      user.allowed?("dental:requisition:dispense")
    end

    def receive?
      user.allowed?("dental:requisition:receive")
    end

    def cancel?
      user.allowed?("dental:requisition:write")
    end
  end
end
