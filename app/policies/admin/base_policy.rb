module Admin
  class BasePolicy < ApplicationPolicy
    private

    def admin_access?
      user.allowed?("admin:access")
    end
  end
end
