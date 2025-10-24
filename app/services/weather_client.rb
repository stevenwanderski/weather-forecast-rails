class WeatherClient
  API_URL = "https://api.weatherapi.com/v1/forecast.json"

  FetchResult = Struct.new(
    :forecast,
    :success,
    keyword_init: true
  )

  def self.fetch(postal:)
    begin
      response = Faraday.get(API_URL, {
        q: postal,
        key: ENV["WEATHER_API_KEY"]
      })

      if !response.success?
        Rails.logger.error("[WeatherClient] API response error: #{response.body}")

        return FetchResult.new(
          forecast: nil,
          success: false
        )
      end

      forecast = parse_response(response)

      FetchResult.new(
        forecast: forecast,
        success: true
      )
    rescue => e
      Rails.logger.error("[WeatherClient] Fetch class error: #{e.message}")

      FetchResult.new(
        forecast: nil,
        success: false
      )
    end
  end

  def self.parse_response(response)
    parsed = JSON.parse(response.body)

    {
      temp_current: parsed["current"]["temp_f"].round,
      temp_high: parsed["forecast"]["forecastday"][0]["day"]["maxtemp_f"].round,
      temp_low: parsed["forecast"]["forecastday"][0]["day"]["mintemp_f"].round
    }
  end
end
