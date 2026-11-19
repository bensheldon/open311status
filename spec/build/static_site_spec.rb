# frozen_string_literal: true

require 'rails_helper'

# Browser tests against the Parklife output. Run `bin/parklife build` first,
# then `bin/rspec --tag build`.
RSpec.describe 'Built static site', :build, type: :feature do
  it 'serves pages without the .html extension' do
    visit '/about'

    expect(page).to have_css('h1', text: 'About Open311 Status')
  end

  it 'searches service requests with the built index' do
    visit '/search?q=pothole'

    within('#search-results') do
      expect(page).to have_css('li a[href^="/cities/"]', minimum: 1).or have_text('No service requests found')
    end
  end
end
