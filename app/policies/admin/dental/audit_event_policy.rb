module Admin
  module Dental
    class AuditEventPolicy < ::Admin::BasePolicy
      def index?
        admin_access?
      end

      class Scope < ApplicationPolicy::Scope
        def resolve
          return scope.none unless user.allowed?("admin:access")

          scope.all
        end
      end
    end
  end
end
