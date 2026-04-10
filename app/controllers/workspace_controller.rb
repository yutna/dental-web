class WorkspaceController < ApplicationController
  before_action :require_signed_in!

  def show
    authorize :workspace, :show?

    @result = Workspace::AppointmentRowsQuery.call(
      search: filter_params[:search],
      status: filter_params[:status]
    )
  rescue StandardError
    @result = {
      rows: [],
      filters: {
        search: filter_params[:search].to_s,
        status: filter_params[:status].to_s
      },
      summary: {
        total: 0,
        in_progress: 0,
        ready: 0,
        completed: 0
      },
      status_options: Workspace::AppointmentRowsQuery::STATUS_OPTIONS,
      error: true
    }
  end

  private

  def filter_params
    params.permit(:search, :status)
  end
end
