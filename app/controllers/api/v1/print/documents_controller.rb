module Api
  module V1
    module Print
      class DocumentsController < BaseController
        def show
          visit_id = params[:visit_id]
          type = params[:type].to_s
          snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: visit_id)

          context = Struct.new(:stage, :type).new(snapshot[:current_stage], type)
          unless Dental::PrintPolicy.new(current_principal, context).show?
            raise Pundit::NotAuthorizedError
          end

          data = case type
          when "treatment_summary"
                   Dental::Print::TreatmentSummaryQuery.call(visit_id: visit_id)
          when "certificate"
                   Dental::Print::TreatmentSummaryQuery.call(visit_id: visit_id)
          when "dental_chart"
                   Dental::Print::DentalChartQuery.call(visit_id: visit_id)
          else
                   raise Dental::Errors::NotFound.new(details: { type: type })
          end

          render json: {
            data: {
              visit_id: visit_id,
              type: type,
              payload: data
            }
          }
        end
      end
    end
  end
end
