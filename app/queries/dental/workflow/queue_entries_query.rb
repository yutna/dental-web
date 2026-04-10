module Dental
  module Workflow
    class QueueEntriesQuery < BaseQuery
      DEFAULT_ROWS_PROVIDER = lambda {
        Workspace::AppointmentRowsQuery::SAMPLE_ROWS
      }

      def call(loading: false, rows_provider: DEFAULT_ROWS_PROVIDER)
        return loading_response if loading

        rows = Array(rows_provider.call)
        return empty_response if rows.empty?

        populated_response(rows)
      rescue StandardError => e
        error_response(e)
      end

      private

      def loading_response
        {
          state: "loading",
          rows: [],
          summary: zero_summary,
          error: false
        }
      end

      def empty_response
        {
          state: "empty",
          rows: [],
          summary: zero_summary,
          error: false
        }
      end

      def populated_response(rows)
        {
          state: "populated",
          rows: rows,
          summary: build_summary(rows),
          error: false
        }
      end

      def error_response(error)
        {
          state: "error",
          rows: [],
          summary: zero_summary,
          error: true,
          error_message: error.message
        }
      end

      def build_summary(rows)
        {
          total: rows.count,
          in_progress: rows.count { |row| row[:status] == "in_progress" },
          ready: rows.count { |row| row[:status] == "ready" },
          completed: rows.count { |row| row[:status] == "completed" }
        }
      end

      def zero_summary
        {
          total: 0,
          in_progress: 0,
          ready: 0,
          completed: 0
        }
      end
    end
  end
end
