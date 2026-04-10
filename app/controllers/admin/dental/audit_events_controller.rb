module Admin
  module Dental
    class AuditEventsController < ::Admin::BaseController
      def index
        authorize([ :admin, :dental, :audit_event ])

        @filters = filter_params.to_h
        @audit_events = ::Dental::Admin::AuditEventsQuery.call(filters: @filters)
      end

      private

      def filter_params
        params.permit(:actor_id, :action, :resource_type, :from, :to, :limit)
      end
    end
  end
end
