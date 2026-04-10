module Dental
  class HomeController < BaseController
    def show
      render plain: "Dental home"
    end
  end
end
