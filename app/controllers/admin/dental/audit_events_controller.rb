module Admin
  module Dental
    class AuditEventsController < ::Admin::BaseController
      def index
        authorize([ :admin, :dental, :audit_event ])

        @filters = filter_params.to_h.symbolize_keys
        @audit_events = ::Dental::Admin::AuditEventsQuery.call(filters: @filters)
      end

      private

      def filter_params
        params.permit(:actor_id, :event_action, :resource_type, :from, :to, :limit)
      end
    end
  end
end
