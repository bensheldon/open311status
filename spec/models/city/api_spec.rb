# frozen_string_literal: true

require 'rails_helper'

RSpec.describe City::Api do
  let(:city) { City.new('chicago') }
  let(:api) { described_class.new(city) }

  it 'fetches the service list and records a status' do
    stub_request(:get, %r{cityofchicago\.org/open311/v2/services\.json}).to_return(body: Rails.root.join('spec/fixtures/service_list.json').read, headers: { 'Content-Type' => 'application/json' })

    definitions = api.fetch_service_list
    expect(definitions.size).to eq fixture_json('service_list').size
    expect(city.service_list_status.http_code).to eq 200
  end

  it 'fetches service requests and merges them' do
    stub_request(:get, %r{cityofchicago\.org/open311/v2/requests\.json}).to_return(body: Rails.root.join('spec/fixtures/service_requests.json').read, headers: { 'Content-Type' => 'application/json' })

    requests = api.fetch_service_requests
    expect(requests).not_to be_empty
    expect(city.service_requests.map(&:service_request_id)).to include(requests.first['service_request_id'])
    expect(city.service_requests_status.http_code).to eq 200
  end

  it 'records errors without raising' do
    stub_request(:get, /services\.json/).to_return(status: 503)

    expect(api.fetch_service_list).to eq []
    expect(city.service_list_status.http_code).to eq 503
    expect(city.service_list_status.title).to eq 'Error'
  end

  it 'backfills by shrinking ranges that hit the page limit' do
    full_page = Array.new(50) { |i| { 'service_request_id' => "full-#{i}" } }
    responses = [full_page.to_json, [{ 'service_request_id' => 'a' }].to_json]
    stub_request(:get, /requests\.json/).to_return { { body: responses.shift || '[]', headers: { 'Content-Type' => 'application/json' } } }

    api.backfill_service_requests(start_at: 2.days.ago)
    expect(a_request(:get, /requests\.json/)).to have_been_made.at_least_times(3)
    expect(city.service_requests.map(&:service_request_id)).to include('a')
    expect(city.statuses).to be_empty
  end
end
