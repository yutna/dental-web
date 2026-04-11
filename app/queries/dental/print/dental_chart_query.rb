module Dental
  module Print
    class DentalChartQuery < BaseQuery
      def call(visit_id:)
        queue_entry = DentalQueueEntry.find_by(visit_id: visit_id)
        chart_records = DentalClinicalChartRecord.where(visit_id: visit_id).order(:tooth_code, :occurred_at)

        teeth = chart_records.group_by(&:tooth_code).transform_values do |records|
          records.map { |r| chart_entry(r) }
        end

        {
          visit_id: visit_id,
          patient_name: queue_entry&.patient_name,
          patient_hn: queue_entry&.mrn,
          visit_date: queue_entry&.starts_at,
          teeth: teeth,
          total_teeth: teeth.keys.size,
          total_entries: chart_records.size
        }
      end

      private

      def chart_entry(record)
        {
          charting_code: record.charting_code,
          surface_codes: record.surface_codes,
          root_codes: record.root_codes,
          piece_codes: record.piece_codes,
          note: record.note,
          occurred_at: record.occurred_at
        }
      end
    end
  end
end
