module Dental
  module Workflow
    class RegisterQueueEntry < BaseUseCase
      def call(
        visit_id:,
        patient_name:,
        mrn:,
        service:,
        starts_at:,
        status:,
        source:,
        actor_id: nil,
        dentist: nil,
        metadata: {}
      )
        entry = DentalQueueEntry.find_or_initialize_by(visit_id: visit_id)
        created = entry.new_record?

        entry.assign_attributes(
          patient_name: patient_name,
          mrn: mrn,
          service: service,
          starts_at: starts_at,
          status: status,
          source: source,
          actor_id: actor_id,
          dentist: dentist,
          metadata_json: metadata.to_json
        )
        entry.save!

        { created: created, entry: entry }
      end
    end
  end
end
