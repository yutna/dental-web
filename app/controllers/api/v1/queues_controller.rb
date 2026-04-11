module Api
  module V1
    class QueuesController < BaseController
      def index
        authorize([ :dental, :visit ], :show?)

        scope = DentalQueueEntry.ordered_dashboard
        scope = apply_filters(scope)
        total = scope.count
        records = scope.offset((page_number - 1) * per_page).limit(per_page)

        render_collection(records, QueueEntrySerializer, total: total)
      end

      def create
        authorize([ :dental, :visit ], :transition?)

        result = Dental::Workflow::RegisterQueueEntry.call(
          visit_id: queue_params[:visit_id],
          patient_name: queue_params[:patient_name],
          mrn: queue_params[:mrn],
          service: queue_params[:service],
          starts_at: queue_params[:starts_at],
          status: queue_params[:status] || "scheduled",
          source: queue_params[:source] || "walk_in",
          dentist: queue_params[:dentist]
        )

        render_resource(result[:entry], QueueEntrySerializer, status: :created)
      end

      private

      def apply_filters(scope)
        scope = scope.where(status: params[:status]) if params[:status].present?
        if params[:search].present?
          query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:search])}%"
          scope = scope.where("patient_name LIKE ? OR mrn LIKE ?", query, query)
        end
        scope
      end

      def queue_params
        params.permit(:visit_id, :patient_name, :mrn, :service, :dentist, :starts_at, :status, :source)
      end
    end
  end
end
