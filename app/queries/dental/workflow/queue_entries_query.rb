module Dental
  module Workflow
    class QueueEntriesQuery < BaseQuery
      STATUS_OPTIONS = %w[scheduled in_progress ready waiting_payment completed].freeze
      SOURCE_OPTIONS = %w[appointment_sync walk_in referral].freeze
      DEFAULT_ROWS_PROVIDER = lambda {
        if DentalQueueEntry.exists?
          DentalQueueEntry.ordered_dashboard.map do |entry|
            {
              id: entry.visit_id,
              patient_name: entry.patient_name,
              mrn: entry.mrn,
              service: entry.service,
              dentist: entry.dentist,
              starts_at: entry.starts_at,
              status: entry.status,
              source: entry.source
            }
          end
        else
          Workspace::AppointmentRowsQuery::SAMPLE_ROWS
        end
      }

      def call(loading: false, search: nil, status: nil, source: nil, rows_provider: DEFAULT_ROWS_PROVIDER)
        filters = normalized_filters(search:, status:, source:)
        return loading_response(filters:) if loading

        rows = filter_rows(Array(rows_provider.call), filters: filters)
        return empty_response(filters:) if rows.empty?

        populated_response(rows, filters:)
      rescue StandardError => e
        error_response(e, filters:)
      end

      private

      def loading_response(filters:)
        {
          state: "loading",
          rows: [],
          summary: zero_summary,
          error: false,
          filters:,
          status_options: STATUS_OPTIONS,
          source_options: SOURCE_OPTIONS,
          polled_at: Time.current
        }
      end

      def empty_response(filters:)
        {
          state: "empty",
          rows: [],
          summary: zero_summary,
          error: false,
          filters:,
          status_options: STATUS_OPTIONS,
          source_options: SOURCE_OPTIONS,
          polled_at: Time.current
        }
      end

      def populated_response(rows, filters:)
        {
          state: "populated",
          rows: rows,
          summary: build_summary(rows),
          error: false,
          filters:,
          status_options: STATUS_OPTIONS,
          source_options: SOURCE_OPTIONS,
          polled_at: Time.current
        }
      end

      def error_response(error, filters:)
        {
          state: "error",
          rows: [],
          summary: zero_summary,
          error: true,
          error_message: error.message,
          filters:,
          status_options: STATUS_OPTIONS,
          source_options: SOURCE_OPTIONS,
          polled_at: Time.current
        }
      end

      def normalized_filters(search:, status:, source:)
        {
          search: search.to_s.strip,
          status: normalize_value(status, STATUS_OPTIONS),
          source: normalize_value(source, SOURCE_OPTIONS)
        }
      end

      def normalize_value(value, allowed)
        return "" if value.blank?

        value = value.to_s
        allowed.include?(value) ? value : ""
      end

      def filter_rows(rows, filters:)
        rows = filter_by_status(rows, filters[:status])
        rows = filter_by_source(rows, filters[:source])
        filter_by_search(rows, filters[:search])
      end

      def filter_by_status(rows, status)
        return rows if status.blank?

        rows.select { |row| row[:status].to_s == status }
      end

      def filter_by_source(rows, source)
        return rows if source.blank?

        rows.select { |row| row[:source].to_s == source }
      end

      def filter_by_search(rows, search)
        return rows if search.blank?

        needle = search.downcase
        rows.select do |row|
          row.values.any? { |field| field.to_s.downcase.include?(needle) }
        end
      end

      def build_summary(rows)
        {
          total: rows.count,
          in_progress: rows.count { |row| row[:status] == "in_progress" },
          ready: rows.count { |row| row[:status] == "ready" },
          waiting_payment: rows.count { |row| row[:status] == "waiting_payment" },
          completed: rows.count { |row| row[:status] == "completed" }
        }
      end

      def zero_summary
        {
          total: 0,
          in_progress: 0,
          ready: 0,
          waiting_payment: 0,
          completed: 0
        }
      end
    end
  end
end
