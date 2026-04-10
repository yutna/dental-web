module Dental
  class HomeController < BaseController
    def show
      authorize([ :dental, :home ], :show?)
      render plain: "Dental home"
    end
  end
end
