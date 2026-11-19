# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status do
  def build(**attrs)
    described_class.new(request_name: 'service_list', **attrs)
  end

  it 'is a fast success' do
    status = build(http_code: 200, duration_ms: 120)
    expect([status.quality, status.title, status.label_class]).to eq [:success, 'Okay', 'success']
    expect(status.description).to eq 'Server responded in 120 ms'
  end

  it 'is slow over 999 ms' do
    status = build(http_code: 200, duration_ms: 1000)
    expect([status.quality, status.title, status.label_class]).to eq [:slow, 'Slow', 'warning']
    expect(status.description).to eq 'Server slow response of 1000 ms'
  end

  it 'is an error with an HTTP code' do
    status = build(http_code: 503, duration_ms: 50)
    expect([status.quality, status.title, status.label_class]).to eq [:error, 'Error', 'danger']
    expect(status.description).to eq 'Server responded with 503 after 50 ms'
  end

  it 'is an error with a message and no HTTP code' do
    status = build(duration_ms: 50, error_message: 'Timeout::Error: execution expired')
    expect(status.quality).to eq :error
    expect(status.description).to eq "Error processing response after 50 ms: 'Timeout::Error: execution expired'"
  end

  it 'round-trips through to_h' do
    status = build(http_code: 200, duration_ms: 5, created_at: Time.utc(2026, 1, 1))
    expect(described_class.new(**status.to_h.symbolize_keys).to_h).to eq status.to_h
    expect(status.to_h).not_to have_key('error_message')
  end

  it 'rejects unknown request names' do
    expect { described_class.new(request_name: 'other') }.to raise_error(ArgumentError)
  end
end
