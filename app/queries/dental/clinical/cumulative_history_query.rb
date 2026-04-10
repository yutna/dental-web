module Dental
  module Clinical
    class CumulativeHistoryQuery < BaseQuery
      def call(visit_id:)
        patient_hn = resolve_patient_hn(visit_id)
        return empty_result(visit_id) if patient_hn.blank?

        chart_records = DentalClinicalChartRecord.where(patient_hn: patient_hn).order(occurred_at: :desc)
        procedure_records = DentalClinicalProcedureRecord.where(patient_hn: patient_hn).order(occurred_at: :desc)
        image_records = DentalClinicalImageRecord.where(patient_hn: patient_hn).order(captured_at: :desc)

        {
          visit_id: visit_id,
          patient_hn: patient_hn,
          tooth_map: build_tooth_map(chart_records, procedure_records),
          timeline: build_timeline(chart_records, procedure_records, image_records)
        }
      end

      private

      def resolve_patient_hn(visit_id)
        DentalClinicalPost.active.where(visit_id: visit_id).order(posted_at: :desc, id: :desc).pick(:patient_hn)
      end

      def build_tooth_map(chart_records, procedure_records)
        grouped = Hash.new { |acc, key| acc[key] = { "tooth_code" => key, "chart_count" => 0, "procedure_count" => 0, "last_occurred_at" => nil } }

        chart_records.each do |record|
          row = grouped[record.tooth_code]
          row["chart_count"] += 1
          row["last_occurred_at"] = [ row["last_occurred_at"], record.occurred_at ].compact.max
        end

        procedure_records.each do |record|
          next if record.tooth_code.blank?

          row = grouped[record.tooth_code]
          row["procedure_count"] += 1
          row["last_occurred_at"] = [ row["last_occurred_at"], record.occurred_at ].compact.max
        end

        grouped.values.sort_by { |row| row["tooth_code"] }
      end

      def build_timeline(chart_records, procedure_records, image_records)
        rows = []

        chart_records.each do |record|
          rows << {
            "entry_type" => "chart",
            "occurred_at" => record.occurred_at,
            "tooth_code" => record.tooth_code,
            "code" => record.charting_code,
            "note" => record.note
          }
        end

        procedure_records.each do |record|
          rows << {
            "entry_type" => "procedure",
            "occurred_at" => record.occurred_at,
            "tooth_code" => record.tooth_code,
            "code" => record.procedure_item_code,
            "note" => record.note
          }
        end

        image_records.each do |record|
          rows << {
            "entry_type" => "image",
            "occurred_at" => record.captured_at,
            "code" => record.image_type_code,
            "image_ref" => record.image_ref,
            "note" => record.note
          }
        end

        rows.sort_by { |row| row["occurred_at"] || Time.at(0) }.reverse.first(100)
      end

      def empty_result(visit_id)
        {
          visit_id: visit_id,
          patient_hn: nil,
          tooth_map: [],
          timeline: []
        }
      end
    end
  end
end
