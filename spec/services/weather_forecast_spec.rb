require "rails_helper"

RSpec.describe WeatherForecast do
  let(:postal) { "12345" }
  let(:cache_key) { "forecast:#{postal}" }

  before { Rails.cache.clear }
  after  { Rails.cache.clear }

  describe ".fetch" do
    context "when a cached forecast exists" do
      let(:cached_forecast) { { temp_current: 70 } }
      let(:client_class) { class_double("WeatherClient") }

      before do
        Rails.cache.write(cache_key, cached_forecast)
      end

      it "returns the cached forecast and does not call the client" do
        expect(client_class).not_to receive(:fetch)

        result = described_class.fetch(postal: postal, client_class: client_class)

        expect(result.success).to be true
        expect(result.is_cached).to be true
        expect(result.forecast).to eq(cached_forecast)
      end
    end

    context "when no cached forecast exists" do
      let(:forecast_data) { { temp_current: 60 } }

      context "and the client returns success" do
        let(:client_class) { double("client_class") }

        before do
          allow(client_class).to receive(:fetch).with(postal: postal).and_return(
            double(success: true, forecast: forecast_data)
          )
        end

        it "returns the forecast, marks is_cached false, and writes to the cache" do
          result = described_class.fetch(postal: postal, client_class: client_class)

          expect(result.success).to be true
          expect(result.is_cached).to be false
          expect(result.forecast).to eq(forecast_data)
          expect(Rails.cache.read(cache_key)).to eq(forecast_data)
        end
      end

      context "and the client returns failure" do
        let(:client_class) { double("client_class") }

        before do
          allow(client_class).to receive(:fetch).with(postal: postal).and_return(
            double(success: false)
          )
        end

        it "returns a failed result and does not write to the cache" do
          result = described_class.fetch(postal: postal, client_class: client_class)

          expect(result.success).to be false
          expect(result.is_cached).to be_nil
          expect(result.forecast).to be_nil
          expect(Rails.cache.read(cache_key)).to be_nil
        end
      end
    end
  end
end
