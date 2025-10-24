class WeatherForecast
  CACHE_EXPIRY = 5.seconds

  Result = Struct.new(
    :forecast,
    :is_cached,
    :success,
    keyword_init: true
  )

  def self.fetch(postal:, client_class: WeatherClient)
    cache_key = "forecast:#{postal}"

    cached_forecast = Rails.cache.read(cache_key)

    if cached_forecast
      return Result.new(
        forecast: cached_forecast,
        is_cached: true,
        success: true
      )
    end

    result = client_class.fetch(postal: postal)

    if !result[:success]
      return Result.new(
        success: false
      )
    end

    Rails.cache.write(cache_key, result[:forecast], expires_in: CACHE_EXPIRY)

    Result.new(
      forecast: result[:forecast],
      is_cached: false,
      success: true
    )
  end
end
