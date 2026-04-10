module Admin
  module Dental
    module MasterData
      class ProcedureItemsController < ::Admin::BaseController
        before_action :set_procedure_item, only: %i[edit update destroy approve_price_change]

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
            record_audit_event("procedure_item.created", @procedure_item)
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

          if maker_checker_required?
            change_request = ::Admin::Dental::MasterData::SubmitPriceChangeRequest.call(
              item: @procedure_item,
              requested_by_id: current_principal.id,
              attributes: procedure_item_params.slice(:price_opd, :price_ipd)
            )
            record_audit_event("procedure_item.price_change_requested", @procedure_item, change_request_id: change_request.id)

            redirect_to admin_dental_master_data_procedure_items_path,
                        notice: t("admin.dental.procedure_items.change_request_submitted")
            return
          end

          if @procedure_item.update(procedure_item_params)
            record_audit_event("procedure_item.updated", @procedure_item)
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

        def approve_price_change
          authorize([ :admin, :dental, :master_data, @procedure_item ])

          request = DentalMasterDataChangeRequest.pending.find(params[:change_request_id])
          unless request.approve!(approver_id: current_principal.id)
            redirect_to admin_dental_master_data_procedure_items_path,
                        alert: t("admin.dental.procedure_items.self_approval_not_allowed")
            return
          end

          @procedure_item.update!(request.payload.slice("price_opd", "price_ipd"))
          record_audit_event("procedure_item.price_change_approved", @procedure_item, change_request_id: request.id)

          redirect_to admin_dental_master_data_procedure_items_path,
                      notice: t("admin.dental.procedure_items.change_request_approved")
        end

        def destroy
          authorize([ :admin, :dental, :master_data, @procedure_item ])
          message = if @procedure_item.coverages.exists?
            @procedure_item.update!(active: false)
            record_audit_event("procedure_item.deactivated_referenced", @procedure_item)
            t("admin.dental.procedure_items.deactivated_referenced")
          elsif @procedure_item.active?
            @procedure_item.update!(active: false)
            record_audit_event("procedure_item.deactivated", @procedure_item)
            t("admin.dental.procedure_items.deactivated")
          else
            t("admin.dental.procedure_items.already_inactive")
          end

          redirect_to admin_dental_master_data_procedure_items_path,
                      notice: message
        end

        def bulk_import_preview
          authorize([ :admin, :dental, :master_data, DentalProcedureItem ])

          result = ::Admin::Dental::MasterData::ProcedureItemBulkImport.call(
            rows: bulk_import_rows,
            overwrite: false
          )
          record_audit_event("procedure_item.bulk_import_preview", DentalProcedureItem, rows: bulk_import_rows.size)

          render json: result
        end

        def bulk_import_apply
          authorize([ :admin, :dental, :master_data, DentalProcedureItem ])

          result = ::Admin::Dental::MasterData::ProcedureItemBulkImport.call(
            rows: bulk_import_rows,
            overwrite: params[:overwrite] == "true"
          )
          record_audit_event("procedure_item.bulk_import_apply", DentalProcedureItem, rows: bulk_import_rows.size, overwrite: params[:overwrite] == "true")

          render json: result
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

        def maker_checker_required?
          params[:require_approval] == "true" && sensitive_price_change?
        end

        def sensitive_price_change?
          attrs = procedure_item_params
          attrs[:price_opd].to_s != @procedure_item.price_opd.to_s ||
            attrs[:price_ipd].to_s != @procedure_item.price_ipd.to_s
        end

        def record_audit_event(action, resource, metadata = {})
          ::Admin::Dental::AuditLogger.call(
            actor_id: current_principal.id,
            action: action,
            resource: resource,
            metadata: metadata
          )
        end

        def bulk_import_rows
          params.expect(rows: [
            [
              :procedure_group_id,
              :code,
              :name,
              :price_opd,
              :price_ipd,
              :active,
              :lock_version
            ]
          ])
        end
      end
    end
  end
end
