module Admin
  module Dental
    class AuditLogger < ::BaseUseCase
      def call(actor_id:, action:, resource:, metadata: {})
        resource_type = resource.is_a?(Class) ? resource.name : resource.class.name
        resource_id = resource.respond_to?(:id) ? resource.id : nil

        DentalAdminAuditEvent.create!(
          actor_id: actor_id,
          action: action,
          resource_type: resource_type,
          resource_id: resource_id,
          metadata_json: metadata.to_json,
          created_at: Time.current
        )
      end
    end
  end
end
