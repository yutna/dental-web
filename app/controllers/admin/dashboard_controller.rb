module Admin
  class DashboardController < BaseController
    def show
      authorize([ :admin, :dashboard ], :show?)
      @clinic_services_count = ClinicService.count
      @active_services_count = ClinicService.active.count
    end
  end
end
