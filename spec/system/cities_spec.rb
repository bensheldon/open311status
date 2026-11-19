# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cities' do
  before { write_city_data('chicago') }

  it 'shows every configured city' do
    visit root_path
    City.all.map(&:name).each { |name| expect(page).to have_text(name) }
  end

  it 'follows a service request permalink' do
    request = City.find('chicago').service_requests.first
    visit requests_path
    find("a[href='#{service_request_path(request)}']").click
    expect(page).to have_text(request.raw_data['service_name'])
    expect(page).to have_current_path(service_request_path(request))
  end

  it 'navigates to About' do
    visit root_path
    click_on 'About'
    expect(page).to have_css('h1', text: 'About Open311 Status')
  end

  describe 'charts', :js do
    it 'draws the charts on the home page' do
      visit '/'

      expect(page).to have_css('[data-controller="line-chart"] canvas')
      expect(page).to have_css('[data-controller="sparkline"] canvas', count: all('[data-controller="sparkline"]').size)
    end

    it 'navigates to a city page with a chart' do
      visit '/'
      city = first('tbody td strong a')
      name = city.text
      city.click

      expect(page).to have_css('h1', text: name)
      expect(page).to have_css('[data-controller="line-chart"] canvas')
    end

    it 'makes no external requests' do
      visit '/'
      expect(page).to have_css('[data-controller="line-chart"] canvas')

      external = page.driver.browser.network.traffic.reject { |exchange| exchange.request.url.start_with?('http://127.0.0.1') }
      expect(external.filter_map(&:response)).to be_empty
    end
  end
end
