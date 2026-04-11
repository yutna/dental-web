module Admin
  module Dental
    module MasterData
      class ReferencesController < ::Admin::BaseController
        before_action :set_reference, only: %i[edit update destroy]

        def index
          authorize([ :admin, :dental, :master_data, DentalImageTypeReference ])
          @references = policy_scope([ :admin, :dental, :master_data, DentalImageTypeReference ])
        end

        def new
          @reference = DentalImageTypeReference.new(active: true)
          authorize([ :admin, :dental, :master_data, @reference ])
        end

        def create
          @reference = DentalImageTypeReference.new(reference_params)
          authorize([ :admin, :dental, :master_data, @reference ])

          if @reference.save
            record_audit_event("reference.created", @reference)
            redirect_to admin_dental_master_data_references_path,
                        notice: t("admin.dental.references.created")
          else
            render :new, status: :unprocessable_content
          end
        end

        def edit
          authorize([ :admin, :dental, :master_data, @reference ])
        end

        def update
          authorize([ :admin, :dental, :master_data, @reference ])

          if @reference.update(reference_params)
            record_audit_event("reference.updated", @reference)
            redirect_to admin_dental_master_data_references_path,
                        notice: t("admin.dental.references.updated")
          else
            render :edit, status: :unprocessable_content
          end
        end

        def destroy
          authorize([ :admin, :dental, :master_data, @reference ])
          @reference.update!(active: false)
          record_audit_event("reference.deactivated", @reference)

          redirect_to admin_dental_master_data_references_path,
                      notice: t("admin.dental.references.deactivated")
        end

        private

        def set_reference
          @reference = DentalImageTypeReference.find(params[:id])
        end

        def reference_params
          params.expect(dental_image_type_reference: %i[code name active])
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
