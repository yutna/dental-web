module Dental
  module Clinical
    class WorkspacesController < Dental::BaseController
      def show
        authorize([ :dental, :clinical ], :read?)

        @visit_id = params[:visit_id]
        @tab = params[:tab].presence || "screening"
        @snapshot = Dental::Workflow::VisitSnapshotQuery.call(visit_id: @visit_id)
        @queue_entry = DentalQueueEntry.find_by(visit_id: @visit_id)
      end
    end
  end
end
