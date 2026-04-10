module Admin
  module Dental
    module MasterData
      class ProcedureItemBulkImport < ::BaseUseCase
        def call(rows:, overwrite: false)
          rows = Array(rows)
          applied = []
          conflicts = []
          errors = []

          rows.each_with_index do |raw_row, index|
            row = raw_row.to_h.deep_symbolize_keys
            code = row[:code].to_s.strip.upcase

            if code.blank?
              errors << { row: index, code: nil, reason: "missing_code" }
              next
            end

            item = DentalProcedureItem.find_by(code: code)
            if item
              incoming_lock = row[:lock_version]
              if !overwrite && incoming_lock.present? && incoming_lock.to_i != item.lock_version
                conflicts << {
                  row: index,
                  code: code,
                  reason: "stale_lock_version",
                  current_lock_version: item.lock_version,
                  incoming_lock_version: incoming_lock.to_i
                }
                next
              end

              item.update!(attributes_for_update(row))
            else
              item = DentalProcedureItem.create!(attributes_for_create(row))
            end

            applied << { row: index, code: item.code, id: item.id }
          rescue ActiveRecord::RecordInvalid => e
            errors << { row: index, code: code, reason: "validation_error", message: e.record.errors.full_messages.join(", ") }
          end

          {
            total_rows: rows.size,
            applied_count: applied.size,
            conflict_count: conflicts.size,
            error_count: errors.size,
            applied: applied,
            conflicts: conflicts,
            errors: errors
          }
        end

        private

        def attributes_for_update(row)
          {
            procedure_group_id: row.fetch(:procedure_group_id),
            name: row.fetch(:name),
            price_opd: row.fetch(:price_opd),
            price_ipd: row.fetch(:price_ipd),
            active: row.fetch(:active, true)
          }
        end

        def attributes_for_create(row)
          attributes_for_update(row).merge(code: row.fetch(:code))
        end
      end
    end
  end
end
