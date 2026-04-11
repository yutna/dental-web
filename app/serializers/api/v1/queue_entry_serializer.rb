module Api
  module V1
    class QueueEntrySerializer < ::BaseSerializer
      class << self
        def serialize(entry)
          {
            id: entry.id,
            visit_id: entry.visit_id,
            patient_name: entry.patient_name,
            mrn: entry.mrn,
            service: entry.service,
            dentist: entry.dentist,
            starts_at: entry.starts_at,
            status: entry.status,
            source: entry.source,
            metadata: entry.metadata,
            created_at: entry.created_at&.iso8601,
            updated_at: entry.updated_at&.iso8601
          }
        end
      end
    end
  end
end
