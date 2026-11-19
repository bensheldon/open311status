# frozen_string_literal: true

require 'rails_helper'

# Browser tests against the Parklife output, built from fake data:
#   DATA_PATH=tmp/fake-data bin/rails data:fake
#   DATA_PATH=tmp/fake-data bin/parklife build
#   bin/rspec --tag build
RSpec.describe 'Built static site', :build, type: :feature do
  it 'serves pages without the .html extension' do
    visit '/about'

    expect(page).to have_css('h1', text: 'About Open311 Status')
  end

  it 'finds a service request from the fake data with search' do
    visit '/search?q=building+violation'

    within('#search-results') do
      expect(page).to have_link('Building Violation in Chicago, IL', href: '/cities/chicago/requests/14-01100627')
      expect(page).to have_css('mark', text: /building/i)
    end
  end
end
