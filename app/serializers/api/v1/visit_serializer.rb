module Api
  module V1
    class VisitSerializer < ::BaseSerializer
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

        def serialize_with_timeline(entry, timeline_entries)
          serialize(entry).merge(
            timeline: timeline_entries.map { |t| serialize_timeline_entry(t) }
          )
        end

        private

        def serialize_timeline_entry(entry)
          {
            id: entry.id,
            event_type: entry.event_type,
            from_stage: entry.from_stage,
            to_stage: entry.to_stage,
            actor_id: entry.actor_id,
            metadata: entry.metadata,
            created_at: entry.created_at&.iso8601
          }
        end
      end
    end
  end
end
