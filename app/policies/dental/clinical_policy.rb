module Dental
  class ClinicalPolicy < BasePolicy
    def read?
      user.allowed?("dental:clinical:read")
    end

    def write?
      user.allowed?("dental:clinical:write")
    end
  end
end
