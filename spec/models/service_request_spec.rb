# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceRequest do
  let(:city) { City.new('chicago') }

  def build(raw)
    described_class.new(city, raw)
  end

  describe '#slug' do
    it 'is a parameterized description' do
      expect(build('description' => 'Pothole on  Main_St - big one').slug).to eq 'pothole-on-main-st-big-one'
    end

    it 'is truncated to SLUG_SIZE without a trailing dash' do
      slug = build('description' => "#{'a' * 99} bcd").slug
      expect(slug.size).to be <= described_class::SLUG_SIZE
      expect(slug).not_to end_with('-')
    end

    it 'is blank without a description' do
      expect(build({}).slug).to eq ''
    end
  end

  describe '#media_url' do
    it 'forces https' do
      expect(build('media_url' => 'http://example.com/a.jpg').media_url).to eq 'https://example.com/a.jpg'
    end

    it 'uses the endpoint host for relative URLs' do
      expect(build('media_url' => '/photos/a.jpg').media_url).to eq "https://#{URI.parse(city.endpoint).host}/photos/a.jpg"
    end

    it 'is nil when blank or invalid' do
      expect(build({}).media_url).to be_nil
      expect(build('media_url' => 'http://exa mple.com/<>').media_url).to be_nil
    end
  end

  describe 'datetimes' do
    it 'parses ISO 8601' do
      expect(build('requested_datetime' => '2026-01-02T03:04:05-05:00').requested_datetime).to eq Time.utc(2026, 1, 2, 8, 4, 5)
    end

    it 'is nil when missing or unparseable' do
      expect(build({}).requested_datetime).to be_nil
      expect(build('requested_datetime' => 'not a date').requested_datetime).to be_nil
      expect(build('updated_datetime' => '').updated_datetime).to be_nil
    end
  end

  describe 'coordinates' do
    it 'parses lat and long as floats' do
      sr = build('lat' => '41.88', 'long' => -87.63)
      expect([sr.latitude, sr.longitude]).to eq [41.88, -87.63]
      expect(sr).to be_coordinates
    end

    it 'is nil when missing, invalid, out of range or 0,0' do
      [{}, { 'lat' => '41.8' }, { 'lat' => 'x', 'long' => '1' }, { 'lat' => '', 'long' => '' },
       { 'lat' => 0, 'long' => 0 }, { 'lat' => 91, 'long' => 1 }].each do |raw|
        sr = build(raw)
        expect([sr.latitude, sr.longitude, sr.coordinates?]).to eq([nil, nil, false]), raw.inspect
      end
    end
  end

  it 'stringifies numeric ids' do
    expect(build('service_request_id' => 123).service_request_id).to eq '123'
  end
end
