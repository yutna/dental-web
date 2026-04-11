module Admin
  module Dental
    module MasterData
      class SupplyItemsController < ::Admin::BaseController
        before_action :set_supply_item, only: %i[edit update destroy]

        def index
          authorize([ :admin, :dental, :master_data, DentalSupplyItem ])
          @supply_items = policy_scope([ :admin, :dental, :master_data, DentalSupplyItem ])
          @supply_categories = DentalSupplyCategory.order(:code)
        end

        def new
          @supply_item = DentalSupplyItem.new(active: true)
          authorize([ :admin, :dental, :master_data, @supply_item ])
          @supply_categories = DentalSupplyCategory.order(:code)
        end

        def create
          @supply_item = DentalSupplyItem.new(supply_item_params)
          authorize([ :admin, :dental, :master_data, @supply_item ])
          @supply_categories = DentalSupplyCategory.order(:code)

          if @supply_item.save
            record_audit_event("supply_item.created", @supply_item)
            redirect_to admin_dental_master_data_supply_items_path,
                        notice: t("admin.dental.supply_items.created")
          else
            render :new, status: :unprocessable_content
          end
        end

        def edit
          authorize([ :admin, :dental, :master_data, @supply_item ])
          @supply_categories = DentalSupplyCategory.order(:code)
        end

        def update
          authorize([ :admin, :dental, :master_data, @supply_item ])
          @supply_categories = DentalSupplyCategory.order(:code)

          if @supply_item.update(supply_item_params)
            record_audit_event("supply_item.updated", @supply_item)
            redirect_to admin_dental_master_data_supply_items_path,
                        notice: t("admin.dental.supply_items.updated")
          else
            render :edit, status: :unprocessable_content
          end
        end

        def destroy
          authorize([ :admin, :dental, :master_data, @supply_item ])
          @supply_item.update!(active: false)
          record_audit_event("supply_item.deactivated", @supply_item)

          redirect_to admin_dental_master_data_supply_items_path,
                      notice: t("admin.dental.supply_items.deactivated")
        end

        private

        def set_supply_item
          @supply_item = DentalSupplyItem.find(params[:id])
        end

        def supply_item_params
          params.expect(dental_supply_item: %i[supply_category_id code name unit unit_price active])
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
