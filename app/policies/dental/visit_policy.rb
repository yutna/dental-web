module Dental
  class VisitPolicy < BasePolicy
    def show?
      user.allowed?("dental:workflow:read")
    end

    def transition?
      user.allowed?("dental:workflow:write")
    end
  end
end
