# frozen_string_literal: true

require 'rails_helper'

# Browser tests against the Parklife output. Run `bin/parklife build` first,
# then `bin/rspec --tag build`.
RSpec.describe 'Built static site', :build, type: :feature do
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

  it 'serves pages without the .html extension' do
    visit '/about'

    expect(page).to have_css('h1', text: 'About Open311 Status')
  end

  it 'makes no external requests' do
    visit '/'
    expect(page).to have_css('[data-controller="line-chart"] canvas')

    external = page.driver.browser.network.traffic.reject { |exchange| exchange.request.url.start_with?('http://127.0.0.1') }
    expect(external.filter_map(&:response)).to be_empty
  end
end
