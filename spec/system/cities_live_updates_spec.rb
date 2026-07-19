# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cities live updates', :js, :truncation do
  let(:city) { City.instance(:chicago) }

  it 'updates a city row over Turbo Streams without reloading the page' do
    create(:status, :services, city:, http_code: 200, duration_ms: 100)
    create(:status, :requests, city:, http_code: 200, duration_ms: 100)

    visit root_path

    row_selector = "tr##{ActionView::RecordIdentifier.dom_id(city)}"
    expect(page).to have_css(row_selector, text: 'Okay')

    create(:status, :services, city:, http_code: 500, duration_ms: 50, error_message: 'Service Unavailable')
    city.broadcast_status_update

    expect(page).to have_css(row_selector, text: 'Error')
  end
end
