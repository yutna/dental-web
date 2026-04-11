module Api
  module V1
    class RequisitionSerializer < ::BaseSerializer
      class << self
        def serialize(requisition)
          {
            id: requisition.id,
            requisition_id: requisition.requisition_id,
            visit_id: requisition.visit_id,
            requester_id: requisition.requester_id,
            status: requisition.status,
            approved_at: requisition.approved_at&.iso8601,
            dispensed_at: requisition.dispensed_at&.iso8601,
            received_at: requisition.received_at&.iso8601,
            cancelled_at: requisition.cancelled_at&.iso8601,
            line_items: requisition.line_items.map do |line|
              {
                item_type: line.item_type,
                item_code: line.item_code,
                item_name: line.item_name,
                quantity: line.quantity,
                unit: line.unit
              }
            end
          }
        end
      end
    end
  end
end
