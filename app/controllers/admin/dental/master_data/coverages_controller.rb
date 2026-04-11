module Admin
  module Dental
    module MasterData
      class CoveragesController < ::Admin::BaseController
        before_action :set_coverage, only: %i[edit update destroy]

        def index
          authorize([ :admin, :dental, :master_data, DentalProcedureItemCoverage ])
          @coverages = policy_scope([ :admin, :dental, :master_data, DentalProcedureItemCoverage ])
          @procedure_items = DentalProcedureItem.order(:code)
        end

        def new
          @coverage = DentalProcedureItemCoverage.new(active: true, effective_from: Date.current)
          authorize([ :admin, :dental, :master_data, @coverage ])
          @procedure_items = DentalProcedureItem.order(:code)
        end

        def create
          @coverage = DentalProcedureItemCoverage.new(coverage_params)
          authorize([ :admin, :dental, :master_data, @coverage ])
          @procedure_items = DentalProcedureItem.order(:code)

          if @coverage.save
            record_audit_event("coverage.created", @coverage)
            redirect_to admin_dental_master_data_coverages_path,
                        notice: t("admin.dental.coverages.created")
          else
            render :new, status: :unprocessable_content
          end
        end

        def edit
          authorize([ :admin, :dental, :master_data, @coverage ])
          @procedure_items = DentalProcedureItem.order(:code)
        end

        def update
          authorize([ :admin, :dental, :master_data, @coverage ])

          if maker_checker_required?
            change_request = ::Admin::Dental::MasterData::SubmitPriceChangeRequest.call(
              item: @coverage,
              requested_by_id: current_principal.id,
              attributes: coverage_params.slice(:price_opd, :price_ipd, :copay_amount, :copay_percent)
            )

            record_audit_event("coverage.price_change_requested", @coverage, change_request_id: change_request.id)
            redirect_to admin_dental_master_data_coverages_path,
                        notice: t("admin.dental.coverages.change_request_submitted")
            return
          end

          if @coverage.update(coverage_params)
            record_audit_event("coverage.updated", @coverage)
            redirect_to admin_dental_master_data_coverages_path,
                        notice: t("admin.dental.coverages.updated")
          else
            @procedure_items = DentalProcedureItem.order(:code)
            render :edit, status: :unprocessable_content
          end
        rescue ActiveRecord::StaleObjectError
          @coverage.reload
          @coverage.errors.add(:base, t("admin.dental.coverages.lock_conflict"))
          @procedure_items = DentalProcedureItem.order(:code)
          render :edit, status: :conflict
        end

        def destroy
          authorize([ :admin, :dental, :master_data, @coverage ])
          @coverage.update!(active: false)
          record_audit_event("coverage.deactivated", @coverage)

          redirect_to admin_dental_master_data_coverages_path,
                      notice: t("admin.dental.coverages.deactivated")
        end

        private

        def set_coverage
          @coverage = DentalProcedureItemCoverage.find(params[:id])
        end

        def coverage_params
          params.expect(dental_procedure_item_coverage: %i[
            procedure_item_id
            eligibility_code
            effective_from
            effective_to
            price_opd
            price_ipd
            copay_amount
            copay_percent
            active
            lock_version
          ])
        end

        def maker_checker_required?
          params[:require_approval] == "true" && sensitive_price_change?
        end

        def sensitive_price_change?
          attrs = coverage_params
          attrs[:price_opd].to_s != @coverage.price_opd.to_s ||
            attrs[:price_ipd].to_s != @coverage.price_ipd.to_s ||
            attrs[:copay_amount].to_s != @coverage.copay_amount.to_s ||
            attrs[:copay_percent].to_s != @coverage.copay_percent.to_s
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
