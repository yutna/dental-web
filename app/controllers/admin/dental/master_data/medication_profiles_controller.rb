module Admin
  module Dental
    module MasterData
      class MedicationProfilesController < ::Admin::BaseController
        before_action :set_medication_profile, only: %i[edit update destroy]

        def index
          authorize([ :admin, :dental, :master_data, DentalMedicationProfile ])
          @medication_profiles = policy_scope([ :admin, :dental, :master_data, DentalMedicationProfile ])
        end

        def new
          @medication_profile = DentalMedicationProfile.new(active: true)
          authorize([ :admin, :dental, :master_data, @medication_profile ])
        end

        def create
          @medication_profile = DentalMedicationProfile.new(medication_profile_params)
          authorize([ :admin, :dental, :master_data, @medication_profile ])

          if @medication_profile.save
            record_audit_event("medication_profile.created", @medication_profile)
            redirect_to admin_dental_master_data_medication_profiles_path,
                        notice: t("admin.dental.medication_profiles.created")
          else
            render :new, status: :unprocessable_content
          end
        end

        def edit
          authorize([ :admin, :dental, :master_data, @medication_profile ])
        end

        def update
          authorize([ :admin, :dental, :master_data, @medication_profile ])

          if @medication_profile.update(medication_profile_params)
            record_audit_event("medication_profile.updated", @medication_profile)
            redirect_to admin_dental_master_data_medication_profiles_path,
                        notice: t("admin.dental.medication_profiles.updated")
          else
            render :edit, status: :unprocessable_content
          end
        end

        def destroy
          authorize([ :admin, :dental, :master_data, @medication_profile ])
          @medication_profile.update!(active: false)
          record_audit_event("medication_profile.deactivated", @medication_profile)

          redirect_to admin_dental_master_data_medication_profiles_path,
                      notice: t("admin.dental.medication_profiles.deactivated")
        end

        private

        def set_medication_profile
          @medication_profile = DentalMedicationProfile.find(params[:id])
        end

        def medication_profile_params
          params.expect(dental_medication_profile: %i[code name category active])
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
