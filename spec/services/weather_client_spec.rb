require "rails_helper"

RSpec.describe WeatherClient do
  describe ".fetch" do
    let(:postal) { "60463" }

    context "when the API returns successful response", vcr: { cassette_name: "weatherapi_successful_response" } do
      it "returns success true and a forecast with rounded temperatures" do
        result = described_class.fetch(postal: postal)

        expect(result.success).to be true
        expect(result.forecast).to be_a(Hash)
        expect(result.forecast[:temp_current]).to eq(36)
        expect(result.forecast[:temp_high]).to eq(59)
        expect(result.forecast[:temp_low]).to eq(32)
      end
    end

    context "when the API returns an error", vcr: { cassette_name: "weatherapi_error_response" } do
      it "returns success false and nil forecast" do
        result = described_class.fetch(postal: postal)

        expect(result.success).to be false
        expect(result.forecast).to be_nil
      end
    end
  end
end
