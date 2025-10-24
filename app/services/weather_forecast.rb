class WeatherForecast
  # Default cache expiration is 30 minutes
  CACHE_EXPIRY = ENV.fetch("CACHE_EXPIRY", 30 * 60).to_i

  ForecastResult = Struct.new(
    :forecast,
    :is_cached,
    :success,
    keyword_init: true
  )

  def self.fetch(postal:, client_class: WeatherClient)
    cached_forecast = cache_read(cache_key_for(postal))

    if cached_forecast
      return ForecastResult.new(
        forecast: cached_forecast,
        is_cached: true,
        success: true
      )
    end

    result = client_class.fetch(postal: postal)

    if !result.success
      return ForecastResult.new(
        success: false
      )
    end

    cache_write(cache_key_for(postal), result.forecast)

    ForecastResult.new(
      forecast: result.forecast,
      is_cached: false,
      success: true
    )
  end

  def self.cache_key_for(postal)
    "forecast:#{postal}"
  end

  def self.cache_read(key)
    Rails.cache.read(key)
  end

  def self.cache_write(key, value)
    Rails.cache.write(key, value, expires_in: CACHE_EXPIRY)
  end
end
