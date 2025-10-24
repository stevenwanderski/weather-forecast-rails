# 🌤️ Weather Forecast by Zip Code

URL: https://weather-forecast-2074dcecf4d8.herokuapp.com/

This is a small Rails application that demonstrates a simple weather lookup tool:

- Controller and view that accepts a postal code from a user
- Service layer that fetches and caches a forecast
- HTTP client wrapper around a third-party weather API
- Test suite including unit and system testing patterns

## Tech Stack

- Rails 8.1.0
- Ruby 3.2.8
- PostgreSQL database
- RSpec / Capybara for testing
- Deployed on Heroku

## Project layout (relevant files)

- `app/controllers/home_controller.rb`: user-facing controller. Accepts the postal parameter and delegates to the `WeatherForecast` service.
- `app/views/home/index.html.erb`: the input form and result rendering.
- `app/services/weather_forecast.rb`: orchestrates cache checks, delegates to `WeatherClient`, writes to cache, returns a `ForecastResult` struct.
- `app/services/weather_client.rb`: wraps Faraday, parses the JSON response from the third-party API and returns a `FetchResult` struct.
- `spec/services/weather_forecast_spec.rb`: unit tests for caching behavior and success/failure branches. (Uses in-memory cache in test examples.)
- `spec/services/weather_client_spec.rb`: VCR-backed test to verify that real network calls are handled correctly.

## Core classes

Below is a short description of the key objects and their responsibilities.

1) `WeatherForecast` (app/services/weather_forecast.rb)

- Purpose: orchestrator and cache manager.
- Public API: `WeatherForecast.fetch(postal:, client_class: WeatherClient)`. Returns a `Result` struct with keys `:forecast`, `:is_cached`, and `:success`.
- Behavior:
	- Checks `Rails.cache` for an existing forecast keyed by `"forecast:#{postal}"`.
	- If cached, returns `Result.new(forecast: cached_forecast, is_cached: true, success: true)`.
	- Otherwise calls `client_class.fetch(postal: postal)`.
	- If the client returns `success: false`, returns `Result.new(success: false)`.
	- If the client returns a forecast, its written to the cache with `expires_in: CACHE_EXPIRY` and returns a successful `Result` with `is_cached: false`.

2) `WeatherClient` (app/services/weather_client.rb)

- Purpose: a thin HTTP client and parser for the external weather API.
- Public API: `WeatherClient.fetch(postal:)`. Returns a `Result` struct with keys `:forecast` and `:success`. The `:forecast` key is a hash containing the keys `:temp_current`, `:temp_high`, `:temp_low`.
- Behavior:
	- Calls `Faraday.get(API_URL, q: postal, key: ENV['WEATHER_API_KEY'])`.
	- Parses `response.body` as JSON and extracts `temp_current`, `temp_high`, `temp_low` (rounded).
	- On any exception (network, parse, etc.) returns `{ forecast: nil, success: false }`.

## Environment variables

- `WEATHER_API_KEY`: Obtain an API key from https://www.weatherapi.com/. The `WeatherClient` implementation reads this from `ENV` and passes it as the `key` query parameter.

## Next steps

- Add a more robust caching solution such as Redis or Solid Cache.
- Add an error reporting platform and report to it on known (and unknown) errors. Use a tool like Sentry.
- Add performance metric monitoring with a tool like New Relic.
- This application was generated via a fresh Rails 8 installation and retains much of the provided boilerplate. Consideration should be given to reviewing the included tools and deciding which should remain (Javascript importmaps, Turbo, Stimulus, etc.)
- Add a better frontend UI. Include form validation, loading state, and a dedicated results page.
- Expand from accepting only a postal code to accepting a full address, auto-complete, suggestions, etc.
