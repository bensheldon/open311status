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
end
