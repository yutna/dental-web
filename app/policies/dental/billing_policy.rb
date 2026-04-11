module Dental
  class BillingPolicy < BasePolicy
    def index?
      user.allowed?("dental:billing:read")
    end

    def show?
      user.allowed?("dental:billing:read")
    end

    def sync?
      user.allowed?("dental:billing:sync")
    end
  end
end
