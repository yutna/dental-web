module Dental
  class PrintPolicy < BasePolicy
    def show?
      user.allowed?("dental:print:read")
    end
  end
end
