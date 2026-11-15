# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'data:fetch' do
  before(:all) { Rails.application.load_tasks } # rubocop:disable RSpec/BeforeAfterAll

  it 'writes JSON Lines files per city' do
    stub_request(:get, /services\.json/).to_return(body: Rails.root.join('spec/fixtures/service_list.json').read, headers: { 'Content-Type' => 'application/json' })
    stub_request(:get, /requests\.json/).to_return(body: Rails.root.join('spec/fixtures/service_requests.json').read, headers: { 'Content-Type' => 'application/json' })

    ENV['SLUGS'] = 'chicago'
    expect { Rake::Task['data:fetch'].execute }.to output(/chicago/).to_stdout
  ensure
    ENV.delete('SLUGS')
  end
end
