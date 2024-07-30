# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Sitemaps' do
  let(:city) { City.first }
  let(:service_request) { create(:service_request, city:) }

  before do
    City.load!
  end

  it 'visits the primary sitemap index' do
    visit '/sitemap.xml'
    expect(page).to have_content static_sitemap_url(format: :xml)
    expect(page).to have_content city_sitemap_index_url(City.first.slug, format: :xml)
  end

  it 'visits the per-city index' do
    visit "/sitemaps/#{city.slug}.xml"
    expect(page).to have_content city_day_sitemap_url(city.slug, date: Date.current, format: :xml)
  end

  it 'visits the per-city-per-day sitemap' do
    visit "/sitemaps/#{city.slug}/#{service_request.requested_datetime.to_date}.xml"
    expect(page).to have_content(service_request_url(service_request))
  end

  it 'visits the static sitemap' do
    visit '/sitemaps/static.xml'
    expect(page).to have_content(root_url)
  end
end
