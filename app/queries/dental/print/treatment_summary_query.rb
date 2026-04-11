module Dental
  module Print
    class TreatmentSummaryQuery < BaseQuery
      def call(visit_id:)
        queue_entry = DentalQueueEntry.find_by(visit_id: visit_id)
        screening = latest_post(visit_id, "screening")
        treatment = latest_post(visit_id, "treatment")
        medication = latest_post(visit_id, "medication")
        procedures = DentalClinicalProcedureRecord.where(visit_id: visit_id).order(:occurred_at)
        invoice = DentalInvoice.for_visit(visit_id).first
        line_items = invoice&.line_items&.order(:id) || []

        {
          visit_id: visit_id,
          patient_name: queue_entry&.patient_name,
          patient_hn: queue_entry&.mrn,
          service: queue_entry&.service,
          visit_date: queue_entry&.starts_at,
          screening: screening&.payload || {},
          treatment: treatment&.payload || {},
          medication: medication&.payload || {},
          procedures: procedures.map { |p| procedure_row(p) },
          invoice_id: invoice&.invoice_id,
          total_amount: invoice&.total_amount || 0,
          copay_amount: invoice&.copay_amount || 0,
          payment_status: invoice&.payment_status,
          line_items: line_items.map { |li| line_item_row(li) }
        }
      end

      private

      def latest_post(visit_id, form_type)
        DentalClinicalPost.active
          .where(visit_id: visit_id, form_type: form_type)
          .order(posted_at: :desc, id: :desc)
          .first
      end

      def procedure_row(record)
        {
          procedure_item_code: record.procedure_item_code,
          tooth_code: record.tooth_code,
          surface_codes: record.surface_codes,
          quantity: record.quantity,
          note: record.note
        }
      end

      def line_item_row(item)
        {
          item_type: item.item_type,
          item_code: item.item_code,
          item_name: item.item_name,
          quantity: item.quantity,
          unit_price: item.unit_price,
          amount: item.amount
        }
      end
    end
  end
end
