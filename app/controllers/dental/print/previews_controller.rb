module Dental
  module Print
    class PreviewsController < Dental::BaseController
      layout "print"

      def show
        @visit_id = params[:visit_id]
        @type = params[:type]
        @queue_entry = DentalQueueEntry.find_by(visit_id: @visit_id)
        @snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: @visit_id)

        unless allowed_to_print?
          render :forbidden, status: :forbidden
          return
        end

        unless load_print_data
          render :not_found, status: :not_found
          return
        end

        @watermark_mode = resolve_watermark_mode
      end

      private

      def allowed_to_print?
        context = Struct.new(:stage, :type).new(@snapshot[:current_stage], @type)
        Dental::PrintPolicy.new(current_principal, context).show?
      end

      def load_print_data
        case @type
        when "treatment_summary"
          @data = Dental::Print::TreatmentSummaryQuery.call(visit_id: @visit_id)
          true
        when "certificate"
          @data = Dental::Print::TreatmentSummaryQuery.call(visit_id: @visit_id)
          true
        when "dental_chart"
          @data = Dental::Print::DentalChartQuery.call(visit_id: @visit_id)
          true
        else
          false
        end
      end

      def resolve_watermark_mode
        requested_mode = params[:watermark].to_s.downcase
        return requested_mode if %w[provisional internal final].include?(requested_mode)

        final_stage? ? "final" : "provisional"
      end

      def final_stage?
        @snapshot[:current_stage].to_s == "completed"
      end
    end
  end
end
