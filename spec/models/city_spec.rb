# frozen_string_literal: true

require 'rails_helper'

RSpec.describe City do
  let(:city) { described_class.new('chicago') }

  before { write_city_data('chicago') }

  it 'loads data from YAML files' do
    expect(city.name).to eq 'Chicago, IL'
    expect(city.service_definitions_count).to be_positive
    expect(city.service_requests.size).to be_positive
    expect(city.service_requests.map(&:requested_datetime)).to eq city.service_requests.map(&:requested_datetime).sort.reverse
  end

  it 'summarizes statuses' do
    expect(city.service_list_status.title).to eq 'Okay'
    expect(city.service_requests_status.title).to eq 'Slow'
    expect(city.uptime_percent('service_requests')).to eq 50.0
  end

  it 'buckets service requests by hour over 48 hours' do
    expect(city.bucketed_service_requests.size).to eq 48
    expect(city.total_service_requests).to eq city.service_requests.size
  end

  it 'round-trips through save and prunes old data' do
    city.merge_service_requests([{ 'service_request_id' => 'old', 'requested_datetime' => (City::SERVICE_REQUEST_RETENTION + 1.day).ago.iso8601 }])
    city.add_status(Status.new(request_name: 'service_list', created_at: (City::STATUS_RETENTION + 1.day).ago, http_code: 200))
    count = city.service_requests.size
    city.save

    reloaded = described_class.new('chicago')
    expect(reloaded.service_requests.size).to eq count - 1
    expect(reloaded.statuses.size).to eq 3
  end

  it 'refreshes .all when data files change' do
    expect(described_class.all.find { |c| c.slug == 'bloomington' }.service_requests).to be_empty
    write_city_data('bloomington')
    expect(described_class.find('bloomington').service_requests).not_to be_empty
  end

  it 'writes one YAML file each for service definitions, statuses and requests' do
    city.save
    dir = DataStore.city_dir('chicago')
    expect(dir.join('service_definitions.yml').then { |f| YAML.safe_load_file(f) }.size).to eq city.service_definitions_count
    expect(dir.join('statuses.yml').then { |f| YAML.safe_load_file(f) }.size).to eq city.statuses.size
    expect(dir.join('requests.yml').then { |f| YAML.safe_load_file(f) }.size).to eq city.service_requests.size
  end

  it 'raises a routing error for unknown cities and requests' do
    expect { described_class.find('nowhere') }.to raise_error(ActionController::RoutingError)
    expect { city.find_service_request('missing') }.to raise_error(ActionController::RoutingError)
  end

  it 'has zero uptime with no checks' do
    expect(described_class.new('bloomington').uptime_percent('service_list')).to eq 0.0
  end

  it 'replaces requests with the same id when merging' do
    id = city.service_requests.first.service_request_id
    count = city.service_requests.size
    city.merge_service_requests([{ 'service_request_id' => id, 'status' => 'closed', 'requested_datetime' => 1.minute.ago.iso8601 }])
    expect(city.service_requests.size).to eq count
    expect(city.find_service_request(id).status).to eq 'closed'
  end
end
