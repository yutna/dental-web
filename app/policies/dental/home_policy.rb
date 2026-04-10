module Dental
  class HomePolicy < BasePolicy
    def show?
      user.allowed?("dental:read")
    end
  end
end
