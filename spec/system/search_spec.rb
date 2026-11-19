# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search', :js do
  before do
    write_city_data('chicago')
    build_search_index
  end

  it 'finds a service request from the navigation search box' do
    request = City.find('chicago').service_requests.find { |sr| sr.raw_data['service_name'] == 'Building Violation' }

    visit '/'
    within('nav') do
      fill_in 'navbar-search', with: 'building violation'
      find_field('navbar-search').native.send_keys(:return)
    end

    expect(page).to have_current_path('/search?q=building+violation')
    expect(page).to have_field('search-box', with: 'building violation')
    within('#search-results') do
      expect(page).to have_link('Building Violation in Chicago, IL', href: service_request_path(request))
      expect(page).to have_css('mark', text: /building/i)
    end
  end

  it 'says when nothing matches' do
    visit '/search?q=xyzzyplugh'
    expect(page).to have_text('No service requests found for “xyzzyplugh”')
  end
end
