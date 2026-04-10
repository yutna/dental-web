module Admin
  module Dental
    class DashboardController < Admin::BaseController
      def show
        authorize([ :admin, :dashboard ], :show?)

        result = ::Dental::Admin::DashboardQuery.call
        @summary = result[:summary]
        @totals = result[:totals]
      end
    end
  end
end
