module Admin
  class ClinicServicesController < BaseController
    before_action :set_clinic_service, only: %i[edit update destroy]

    def index
      authorize([ :admin, ClinicService ])
      @clinic_services = policy_scope([ :admin, ClinicService ])
    end

    def new
      @clinic_service = ClinicService.new(active: true, default_duration_minutes: 30)
      authorize([ :admin, @clinic_service ])
    end

    def create
      @clinic_service = ClinicService.new(clinic_service_params)
      authorize([ :admin, @clinic_service ])

      if @clinic_service.save
        redirect_to admin_clinic_services_path, notice: t("admin.clinic_services.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize([ :admin, @clinic_service ])
    end

    def update
      authorize([ :admin, @clinic_service ])

      if @clinic_service.update(clinic_service_params)
        redirect_to admin_clinic_services_path, notice: t("admin.clinic_services.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize([ :admin, @clinic_service ])
      @clinic_service.destroy!

      redirect_to admin_clinic_services_path, notice: t("admin.clinic_services.destroyed")
    end

    private

    def set_clinic_service
      @clinic_service = ClinicService.find(params[:id])
    end

    def clinic_service_params
      params.expect(clinic_service: %i[code name default_duration_minutes active])
    end
  end
end
