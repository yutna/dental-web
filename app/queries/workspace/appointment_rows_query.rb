module Workspace
  class AppointmentRowsQuery < BaseQuery
    STATUS_OPTIONS = %w[scheduled in_progress ready waiting_payment completed].freeze

    SAMPLE_ROWS = [
      {
        id: "AP-1001",
        patient_name: "Somchai J.",
        mrn: "HN-24001",
        chair: "Chair 2",
        service: "Root Canal",
        starts_at: "09:00",
        status: "in_progress",
        dentist: "Dr. Suda",
        source: "appointment_sync"
      },
      {
        id: "AP-1002",
        patient_name: "Anong K.",
        mrn: "HN-24008",
        chair: "Chair 1",
        service: "Dental Cleaning",
        starts_at: "09:30",
        status: "ready",
        dentist: "Dr. Korn",
        source: "walk_in"
      },
      {
        id: "AP-1003",
        patient_name: "Preecha T.",
        mrn: "HN-24014",
        chair: "Chair 4",
        service: "Crown Fitting",
        starts_at: "10:00",
        status: "waiting_payment",
        dentist: "Dr. Nicha",
        source: "appointment_sync"
      },
      {
        id: "AP-1004",
        patient_name: "Sirin P.",
        mrn: "HN-24021",
        chair: "Chair 3",
        service: "Whitening",
        starts_at: "10:30",
        status: "completed",
        dentist: "Dr. Suda",
        source: "referral"
      }
    ].freeze

    def call(search:, status:)
      status = normalize_status(status)
      search = search.to_s.strip.downcase
      rows = SAMPLE_ROWS
      rows = filter_by_status(rows, status)
      rows = filter_by_search(rows, search)

      {
        rows: rows,
        filters: { search: search, status: status },
        summary: build_summary(SAMPLE_ROWS),
        status_options: STATUS_OPTIONS
      }
    end

    private

    def normalize_status(value)
      return "" if value.blank?
      return value if STATUS_OPTIONS.include?(value)

      ""
    end

    def filter_by_status(rows, status)
      return rows if status.blank?

      rows.select { |row| row[:status] == status }
    end

    def filter_by_search(rows, search)
      return rows if search.blank?

      rows.select do |row|
        row.values.any? { |field| field.to_s.downcase.include?(search) }
      end
    end

    def build_summary(rows)
      {
        total: rows.count,
        in_progress: rows.count { |row| row[:status] == "in_progress" },
        ready: rows.count { |row| row[:status] == "ready" },
        completed: rows.count { |row| row[:status] == "completed" }
      }
    end
  end
end
