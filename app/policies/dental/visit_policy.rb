module Dental
  class VisitPolicy < BasePolicy
    def show?
      user.allowed?("dental:workflow:read")
    end

    def transition?
      user.allowed?("dental:workflow:write")
    end

    def check_in?
      transition?
    end

    def sync_appointments?
      transition?
    end
  end
end
