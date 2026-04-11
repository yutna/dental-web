module Dental
  module Admin
    class AuditEventsQuery < BaseQuery
      DEFAULT_LIMIT = 100

      def call(filters: {})
        scoped = DentalAdminAuditEvent.all
        scoped = scoped.where(actor_id: filters[:actor_id]) if filters[:actor_id].present?
        scoped = scoped.where(action: filters[:event_action]) if filters[:event_action].present?
        scoped = scoped.where(resource_type: filters[:resource_type]) if filters[:resource_type].present?
        scoped = scoped.by_event_type(filters[:event_type])

        if filters[:from].present?
          scoped = scoped.where("created_at >= ?", Time.zone.parse(filters[:from]))
        end

        if filters[:to].present?
          scoped = scoped.where("created_at <= ?", Time.zone.parse(filters[:to]))
        end

        limit = filters[:limit].to_i
        limit = DEFAULT_LIMIT if limit <= 0

        scoped.recent_first.limit([ limit, 500 ].min)
      end
    end
  end
end
