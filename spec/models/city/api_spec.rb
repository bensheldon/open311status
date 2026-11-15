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

  it 'records unknown errors as an error message' do
    stub_request(:get, /services\.json/).to_raise(SocketError.new('getaddrinfo failed'))

    api.fetch_service_list
    expect(city.service_list_status.http_code).to be_nil
    expect(city.service_list_status.error_message).to include('getaddrinfo failed')
  end

  it 'keeps existing service definitions when the fetch fails' do
    city.service_definitions = [{ 'service_code' => 'x' }]
    stub_request(:get, /services\.json/).to_return(status: 500)

    expect(api.fetch_service_list.map(&:service_code)).to eq ['x']
  end

  it 'starts fetching from the newest stored request' do
    newest = 2.hours.ago.change(usec: 0)
    city.merge_service_requests([{ 'service_request_id' => '1', 'requested_datetime' => newest.iso8601 }])
    stub = stub_request(:get, /requests\.json/).with(query: hash_including('start_date' => newest.utc.xmlschema)).to_return(body: '[]', headers: { 'Content-Type' => 'application/json' })

    api.fetch_service_requests
    expect(stub).to have_been_requested
  end

  # An Open311 endpoint that, like real ones, returns at most one page of
  # requests in the date range, newest first.
  def stub_paginated_endpoint(requests, page_size: 50, fail_after: nil)
    calls = 0
    stub_request(:get, /requests\.json/).to_return do |request|
      calls += 1
      raise SocketError, 'connection reset' if fail_after && calls > fail_after

      query = Rack::Utils.parse_query(URI(request.uri.to_s).query)
      start_at = Time.zone.parse(query['start_date'])
      end_at = query['end_date'] ? Time.zone.parse(query['end_date']) : Time.current
      page = requests.select { |r| Time.zone.parse(r['requested_datetime']).between?(start_at, end_at) }
                     .sort_by { |r| r['requested_datetime'] }.reverse.first(page_size)
      { body: page.to_json, headers: { 'Content-Type' => 'application/json' } }
    end
  end

  def requests_between(from, to, count)
    Array.new(count) { |i| { 'service_request_id' => "#{from.to_i}-#{i}", 'requested_datetime' => (from + ((to - from) * i / count)).change(usec: 0).iso8601 } }
  end

  context 'when more requests arrive than fit in one page' do
    it 'fetches all of them before advancing the cursor' do
      requests = requests_between(1.day.ago, 1.minute.ago, 120)
      stub_paginated_endpoint(requests)

      api.fetch_service_requests
      expect(city.service_requests.map(&:service_request_id)).to match_array(requests.pluck('service_request_id'))
      expect(city.service_requests_status.http_code).to eq 200
      expect(city.statuses.size).to eq 1
    end

    it 'fetches all of them on the next run too' do
      city.merge_service_requests(requests_between(2.days.ago, 1.day.ago, 10))
      requests = requests_between(1.day.ago + 1.minute, 1.minute.ago, 75)
      stub_paginated_endpoint(requests)

      api.fetch_service_requests
      expect(city.service_requests.size).to eq 85
    end

    it 'does not advance the cursor past unfetched requests when a request fails partway' do
      requests = requests_between(3.days.ago, 1.minute.ago, 300)
      stub_paginated_endpoint(requests, fail_after: 10)

      expect { api.fetch_service_requests }.to raise_error(Faraday::ConnectionFailed)
      fetched = city.service_requests.map(&:service_request_id)
      expect(fetched).not_to be_empty
      cursor = city.latest_requested_datetime
      missing = requests.reject { |r| fetched.include?(r['service_request_id']) }
      expect(missing).not_to be_empty
      expect(missing.map { |r| Time.zone.parse(r['requested_datetime']) }).to all(be >= cursor)
    end
  end

  it 'fetches ranges of requests for backfill without recording statuses' do
    requests = requests_between(City::SERVICE_REQUEST_RETENTION.ago + 1.minute, 1.minute.ago, 200)
    stub_paginated_endpoint(requests)

    expect(api.fetch_service_requests_in_ranges.size).to eq 200
    expect(city.service_requests.size).to eq 200
    expect(city.statuses).to be_empty
  end
end
