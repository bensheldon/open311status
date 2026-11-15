# frozen_string_literal: true

require 'rails_helper'

RSpec.describe City do
  let(:city) { described_class.new('chicago') }

  before { write_city_data('chicago') }

  it 'loads data from JSON Lines files' do
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
    expect(described_class.all.find { |c| c.slug == 'baltimore' }.service_requests).to be_empty
    write_city_data('baltimore')
    expect(described_class.find('baltimore').service_requests).not_to be_empty
  end

  it 'writes requests into one file per day and statuses into one file per month' do
    city.save
    dir = DataStore.city_dir('chicago')
    days = city.service_requests.map { |sr| sr.requested_datetime.utc.strftime('%Y-%m-%d') }.uniq.sort
    expect(dir.glob('requests/*.jsonl').map { |f| f.basename('.jsonl').to_s }.sort).to eq days
    expect(dir.glob('statuses/*.jsonl')).not_to be_empty
    expect(dir.join('service_definitions.jsonl').readlines.size).to eq city.service_definitions_count
  end
end
