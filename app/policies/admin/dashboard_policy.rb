module Admin
  class DashboardPolicy < BasePolicy
    def show?
      admin_access?
    end
  end
end
