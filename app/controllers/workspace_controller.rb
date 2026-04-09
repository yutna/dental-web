class WorkspaceController < ApplicationController
  before_action :require_signed_in!

  def show
    authorize :workspace, :show?

    @result = Workspace::AppointmentRowsQuery.call(
      search: filter_params[:search],
      status: filter_params[:status]
    )
  end

  private

  def filter_params
    params.permit(:search, :status)
  end
end
