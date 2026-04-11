class WorkspaceController < ApplicationController
  before_action :require_signed_in!

  def show
    authorize :workspace, :show?

    @result = Dental::Workflow::QueueEntriesQuery.call(
      loading: queue_loading?,
      search: filter_params[:search],
      status: filter_params[:status],
      source: filter_params[:source]
    )

    respond_to do |format|
      format.turbo_stream if turbo_frame_request?
      format.html
    end
  rescue StandardError
    @result = {
      state: "error",
      rows: [],
      filters: {
        search: filter_params[:search].to_s,
        status: filter_params[:status].to_s,
        source: filter_params[:source].to_s
      },
      summary: {
        total: 0,
        in_progress: 0,
        ready: 0,
        waiting_payment: 0,
        completed: 0
      },
      status_options: Dental::Workflow::QueueEntriesQuery::STATUS_OPTIONS,
      source_options: Dental::Workflow::QueueEntriesQuery::SOURCE_OPTIONS,
      error: true,
      polled_at: Time.current
    }
  end

  private

  def filter_params
    params.permit(:search, :status, :source, :queue_only, :loading)
  end

  def queue_loading?
    ActiveModel::Type::Boolean.new.cast(filter_params[:loading])
  end
end
