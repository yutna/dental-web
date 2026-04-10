module Dental
  module Workflow
    class SyncAppointmentsToQueue < BaseUseCase
      DEFAULT_ROWS_PROVIDER = lambda {
        Workspace::AppointmentRowsQuery::SAMPLE_ROWS
      }

      def call(actor_id:, rows_provider: DEFAULT_ROWS_PROVIDER)
        created_count = 0
        skipped_count = 0
        errors = []

        Array(rows_provider.call).each do |row|
          visit_id = "SYNC-#{row[:id]}"
          result = Dental::Workflow::RegisterQueueEntry.call(
            visit_id: visit_id,
            patient_name: row[:patient_name],
            mrn: row[:mrn],
            service: row[:service],
            starts_at: row[:starts_at],
            status: "scheduled",
            source: "appointment_sync",
            actor_id: actor_id,
            dentist: row[:dentist],
            metadata: {
              appointment_id: row[:id],
              sync_origin: "workspace_appointments"
            }
          )

          if result[:created]
            created_count += 1
          else
            skipped_count += 1
          end
        rescue StandardError => e
          errors << {
            appointment_id: row[:id],
            message: e.message
          }
        end

        {
          created_count: created_count,
          skipped_count: skipped_count,
          error_count: errors.size,
          errors: errors
        }
      end
    end
  end
end
