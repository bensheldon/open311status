# frozen_string_literal: true

require 'rails_helper'

# Browser tests against the Parklife output. Run `bin/parklife build` first,
# then `bin/rspec --tag build`.
RSpec.describe 'Built static site', :build, type: :feature do
  it 'serves pages without the .html extension' do
    visit '/about'

    expect(page).to have_css('h1', text: 'About Open311 Status')
  end

  it 'finds a built service request with search' do
    visit '/requests'
    first('a[href^="/cities/"][href*="/requests/"]').click
    service_name = find('h1').text
    expect(service_name).to be_present

    visit "/search?q=#{CGI.escape(service_name)}"

    within('#search-results') do
      expect(page).to have_css('li a[href*="/requests/"]', text: /\A#{Regexp.escape(service_name)} in /, minimum: 1)
      expect(page).to have_css('mark')
    end
  end
end
