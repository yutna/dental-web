class HomeController < ApplicationController
  before_action :require_signed_in!

  def index
    return if params[:reason] == "workspace_denied"

    redirect_to workspace_path
  end
end
