module Admin
  module Dental
    class AuditLogger < ::BaseUseCase
      def call(actor_id:, action:, resource:, event_type: "admin", metadata: {})
        resource_type = resource.is_a?(Class) ? resource.name : resource.class.name
        resource_id = resource.respond_to?(:id) ? resource.id : nil

        DentalAdminAuditEvent.create!(
          actor_id: actor_id,
          action: action,
          event_type: event_type,
          resource_type: resource_type,
          resource_id: resource_id,
          metadata_json: metadata.to_json,
          created_at: Time.current
        )
      end
    end
  end
end
