module Admin
  module Dental
    module MasterData
      class SupplyCategoriesController < ::Admin::BaseController
        before_action :set_supply_category, only: %i[edit update destroy]

        def index
          authorize([ :admin, :dental, :master_data, DentalSupplyCategory ])
          @supply_categories = policy_scope([ :admin, :dental, :master_data, DentalSupplyCategory ])
        end

        def new
          @supply_category = DentalSupplyCategory.new(active: true)
          authorize([ :admin, :dental, :master_data, @supply_category ])
        end

        def create
          @supply_category = DentalSupplyCategory.new(supply_category_params)
          authorize([ :admin, :dental, :master_data, @supply_category ])

          if @supply_category.save
            record_audit_event("supply_category.created", @supply_category)
            redirect_to admin_dental_master_data_supply_categories_path,
                        notice: t("admin.dental.supply_categories.created")
          else
            render :new, status: :unprocessable_content
          end
        end

        def edit
          authorize([ :admin, :dental, :master_data, @supply_category ])
        end

        def update
          authorize([ :admin, :dental, :master_data, @supply_category ])

          if @supply_category.update(supply_category_params)
            record_audit_event("supply_category.updated", @supply_category)
            redirect_to admin_dental_master_data_supply_categories_path,
                        notice: t("admin.dental.supply_categories.updated")
          else
            render :edit, status: :unprocessable_content
          end
        end

        def destroy
          authorize([ :admin, :dental, :master_data, @supply_category ])
          @supply_category.update!(active: false)
          record_audit_event("supply_category.deactivated", @supply_category)

          redirect_to admin_dental_master_data_supply_categories_path,
                      notice: t("admin.dental.supply_categories.deactivated")
        end

        private

        def set_supply_category
          @supply_category = DentalSupplyCategory.find(params[:id])
        end

        def supply_category_params
          params.expect(dental_supply_category: %i[code name active])
        end

        def record_audit_event(action, resource, metadata = {})
          ::Admin::Dental::AuditLogger.call(
            actor_id: current_principal.id,
            action: action,
            resource: resource,
            metadata: metadata
          )
        end
      end
    end
  end
end
