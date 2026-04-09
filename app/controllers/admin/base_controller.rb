module Admin
  class BaseController < ApplicationController
    before_action :require_signed_in!
  end
end
