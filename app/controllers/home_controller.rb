class HomeController < ApplicationController
  def index
    @postal = params[:postal]
  end
end
