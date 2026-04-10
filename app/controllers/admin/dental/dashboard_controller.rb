module Admin
  module Dental
    class DashboardController < Admin::BaseController
      def show
        authorize([ :admin, :dashboard ], :show?)
        render plain: "Admin dental dashboard"
      end
    end
  end
end
