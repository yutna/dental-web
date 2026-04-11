module Dental
  class HomeController < BaseController
    def show
      authorize([ :dental, :home ], :show?)
    end
  end
end
