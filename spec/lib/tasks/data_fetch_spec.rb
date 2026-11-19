# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'data:fetch' do
  before(:all) { Rails.application.load_tasks } # rubocop:disable RSpec/BeforeAfterAll

  it 'writes YAML files per city' do
    stub_request(:get, /services\.json/).to_return(body: Rails.root.join('spec/fixtures/service_list.json').read, headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, /requests\.json/).to_return(body: Rails.root.join('spec/fixtures/service_requests.json').read, headers: { 'Content-Type' => 'application/json' })

    ENV['SLUGS'] = 'chicago'
    expect { Rake::Task['data:fetch'].execute }.to output(/chicago/).to_stdout
  ensure
    ENV.delete('SLUGS')
  end

  it 'continues with other cities when one fails' do
    stub_request(:get, /services\.json/).to_return(body: '[]', headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, /requests\.json/).to_return(body: '[]', headers: { 'Content-Type' => 'application/json' })
    allow(City).to receive(:new).and_call_original
    allow(City).to receive(:new).with('bloomington').and_raise('boom')

    ENV['SLUGS'] = 'bloomington,chicago'
    expect { Rake::Task['data:fetch'].execute }.to output(/bloomington: RuntimeError: boom.*chicago:|chicago:.*bloomington: RuntimeError: boom/m).to_stdout
    expect(DataStore.city_dir('chicago').join('statuses.yml')).to exist
  ensure
    ENV.delete('SLUGS')
  end

  it 'backfills service requests' do
    stub_request(:get, /requests\.json/).to_return(body: Rails.root.join('spec/fixtures/service_requests.json').read, headers: { 'Content-Type' => 'application/json' })

    ENV['SLUGS'] = 'chicago'
    expect { Rake::Task['data:backfill'].execute }.to output(/chicago: backfilled \d+ requests/).to_stdout
    expect(City.new('chicago').statuses).to be_empty
  ensure
    ENV.delete('SLUGS')
  end

  it 'saves statuses and completed ranges when a backfill fails partway' do
    calls = 0
    stub_request(:get, /requests\.json/).to_return do
      calls += 1
      raise SocketError, 'connection reset' if calls > 3

      { body: [{ 'service_request_id' => calls.to_s, 'requested_datetime' => (6 - calls).days.ago.iso8601 }].to_json, headers: { 'Content-Type' => 'application/json' } }
    end

    ENV['SLUGS'] = 'chicago'
    expect { Rake::Task['data:backfill'].execute }.to output(/chicago: backfill stopped after 3 requests/).to_stdout
    expect(City.new('chicago').service_requests.size).to eq 3
  ensure
    ENV.delete('SLUGS')
  end

  it 'saves statuses when fetching raises an unexpected error' do
    stub_request(:get, /services\.json/).to_return(body: '[]', headers: { 'Content-Type' => 'application/json' })
    allow_any_instance_of(City::Api).to receive(:fetch_service_requests).and_raise('boom') # rubocop:disable RSpec/AnyInstance

    ENV['SLUGS'] = 'chicago'
    expect { Rake::Task['data:fetch'].execute }.to output(/chicago: RuntimeError: boom/).to_stdout
    expect(City.new('chicago').service_list_status).to be_present
  ensure
    ENV.delete('SLUGS')
  end
end
