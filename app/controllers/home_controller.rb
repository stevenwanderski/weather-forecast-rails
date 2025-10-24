class HomeController < ApplicationController
  def index
    @postal = params[:postal]

    if @postal.present?
      result = WeatherForecast.fetch(postal: @postal)

      @has_error = !result[:success]
      @is_cached = result[:is_cached]
      @forecast = result[:forecast]
    end
  end
end
