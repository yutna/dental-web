module Admin
  module Dental
    module MasterData
      class DentalProcedureItemCoveragePolicy < ::Admin::BasePolicy
        def index?
          admin_access?
        end

        def create?
          admin_access?
        end

        def new?
          create?
        end

        def update?
          admin_access?
        end

        def edit?
          update?
        end

        def destroy?
          admin_access?
        end

        class Scope < ApplicationPolicy::Scope
          def resolve
            return scope.none unless user.allowed?("admin:access")

            scope.includes(:procedure_item).order(:id)
          end
        end
      end
    end
  end
end
