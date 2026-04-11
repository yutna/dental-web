module Dental
  module Supply
    class CreateRequisition < BaseUseCase
      def call(requisition_id:, requester_id:, line_items:, visit_id: nil)
        requisition = nil

        ActiveRecord::Base.transaction do
          requisition = DentalRequisition.create!(
            requisition_id: requisition_id,
            requester_id: requester_id,
            visit_id: visit_id,
            status: "pending"
          )

          Array(line_items).each do |item|
            requisition.line_items.create!(
              item_type: item.fetch(:item_type),
              item_code: item.fetch(:item_code),
              item_name: item.fetch(:item_name),
              quantity: item.fetch(:quantity),
              unit: item.fetch(:unit)
            )
          end
        end

        { requisition: requisition }
      end
    end
  end
end
