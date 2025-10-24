require 'rails_helper'

describe 'successful forecast', type: :feature do
  before do
    allow(WeatherClient).to receive(:fetch).and_return(double(
      forecast: { temp_current: 51 },
      success: true
    ))
  end

  it 'shows the forecast' do
    visit '/'
    fill_in 'Postal', with: '60463'
    click_button 'Submit'

    expect(page).to have_content('The current temperature for 60463 is 51°.')
  end
end
