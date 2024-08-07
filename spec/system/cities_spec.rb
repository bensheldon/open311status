# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cities' do
  include ActionView::Helpers::DateHelper

  before do
    City.load!

    City.find_each do |city|
      create(:status, request_name: 'service_list', city:, http_code: 500, created_at: 10.minutes.ago)
      create(:status, request_name: 'service_requests', city:, http_code: 500, created_at: 10.minutes.ago)
    end
  end

  it 'shows all cities on frontpage' do
    visit root_path

    City.find_each do |city|
      expect(page).to have_text city.name
    end
  end

  it 'has a permalink for a request' do
    service_request = create(:service_request, city: City.instance(:chicago))

    visit root_path
    expect(page).to have_text service_request.raw_data['description']
    click_on time_ago_in_words("#{service_request.requested_datetime} ago")

    expect(page).to have_text service_request.raw_data['description']
  end
end
