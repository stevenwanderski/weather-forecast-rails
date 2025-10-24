ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require 'capybara/rspec'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :faraday
  c.configure_rspec_metadata!
  c.filter_sensitive_data('<WEATHER_API_KEY>') { ENV['WEATHER_API_KEY'] }
end

Capybara.server = :puma, { Silent: true }
Capybara.asset_host = 'http://localhost:3000/'
Capybara.javascript_driver = :selenium_headless
Selenium::WebDriver.logger.ignore(:clear_local_storage, :clear_session_storage)
