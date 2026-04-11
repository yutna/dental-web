module Dental
  class ClinicalPolicy < BasePolicy
    def read?
      user.allowed?("dental:workflow:read")
    end

    def write?
      user.allowed?("dental:workflow:write")
    end
  end
end
