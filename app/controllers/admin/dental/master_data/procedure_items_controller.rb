module Admin
  module Dental
    module MasterData
      class ProcedureItemsController < ::Admin::BaseController
        before_action :set_procedure_item, only: %i[edit update destroy]

        def index
          authorize([ :admin, :dental, :master_data, DentalProcedureItem ])
          @procedure_items = policy_scope([ :admin, :dental, :master_data, DentalProcedureItem ])
        end

        def new
          @procedure_item = DentalProcedureItem.new(active: true)
          authorize([ :admin, :dental, :master_data, @procedure_item ])
          load_procedure_groups
        end

        def create
          @procedure_item = DentalProcedureItem.new(procedure_item_params)
          authorize([ :admin, :dental, :master_data, @procedure_item ])

          if @procedure_item.save
            redirect_to admin_dental_master_data_procedure_items_path,
                        notice: t("admin.dental.procedure_items.created")
          else
            load_procedure_groups
            render :new, status: :unprocessable_content
          end
        end

        def edit
          authorize([ :admin, :dental, :master_data, @procedure_item ])
          load_procedure_groups
        end

        def update
          authorize([ :admin, :dental, :master_data, @procedure_item ])

          if @procedure_item.update(procedure_item_params)
            redirect_to admin_dental_master_data_procedure_items_path,
                        notice: t("admin.dental.procedure_items.updated")
          else
            load_procedure_groups
            render :edit, status: :unprocessable_content
          end
        rescue ActiveRecord::StaleObjectError
          @procedure_item.reload
          @procedure_item.errors.add(:base, t("admin.dental.procedure_items.lock_conflict"))
          load_procedure_groups
          render :edit, status: :conflict
        end

        def destroy
          authorize([ :admin, :dental, :master_data, @procedure_item ])
          message = if @procedure_item.coverages.exists?
            @procedure_item.update!(active: false)
            t("admin.dental.procedure_items.deactivated_referenced")
          elsif @procedure_item.active?
            @procedure_item.update!(active: false)
            t("admin.dental.procedure_items.deactivated")
          else
            t("admin.dental.procedure_items.already_inactive")
          end

          redirect_to admin_dental_master_data_procedure_items_path,
                      notice: message
        end

        private

        def set_procedure_item
          @procedure_item = DentalProcedureItem.find(params[:id])
        end

        def load_procedure_groups
          @procedure_groups = DentalProcedureGroup.order(:code)
        end

        def procedure_item_params
          params.expect(dental_procedure_item: [
            :procedure_group_id,
            :code,
            :name,
            :price_opd,
            :price_ipd,
            :active,
            :lock_version
          ])
        end
      end
    end
  end
end
