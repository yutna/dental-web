class WorkspacePolicy < ApplicationPolicy
  def show?
    user.allowed?("workspace:read")
  end
end
