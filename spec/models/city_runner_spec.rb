# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CityRunner do
  let(:log) { StringIO.new }
  let(:logger) { Logger.new(log) }

  it 'yields a City for each slug' do
    slugs = Concurrent::Array.new
    described_class.new(slugs: %w[bloomington chicago], logger: logger).each { |city| slugs << city.slug }

    expect(slugs).to contain_exactly('bloomington', 'chicago')
  end

  it 'runs cities concurrently' do
    latch = Concurrent::CountDownLatch.new(2)
    started_together = Concurrent::Array.new
    described_class.new(slugs: %w[bloomington chicago], threads: 2, logger: logger).each do |city|
      latch.count_down
      started_together << city.slug if latch.wait(5)
    end

    expect(started_together).to contain_exactly('bloomington', 'chicago')
  end

  it 'logs an error in one city and continues with the others' do
    slugs = Concurrent::Array.new
    described_class.new(slugs: %w[bloomington chicago], logger: logger).each do |city|
      raise 'boom' if city.slug == 'bloomington'

      slugs << city.slug
    end

    expect(slugs).to eq ['chicago']
    expect(log.string).to include('bloomington: RuntimeError: boom')
  end

  it 'shuts down its thread pool' do
    pool = Concurrent::FixedThreadPool.new(1)
    allow(Concurrent::FixedThreadPool).to receive(:new).and_return(pool)
    described_class.new(slugs: ['chicago'], logger: logger).each { nil }

    expect(pool).to be_shutdown
  end
end
