module Dental
  class BasePolicy < ApplicationPolicy
    def access?
      false
    end

    def index?
      false
    end

    def show?
      false
    end

    def create?
      false
    end

    def update?
      false
    end

    def destroy?
      false
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.respond_to?(:none) ? scope.none : []
      end
    end
  end
end
