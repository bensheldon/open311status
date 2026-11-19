# frozen_string_literal: true

require 'rails_helper'

RSpec.describe City, '#nearby_service_requests' do
  let(:city) { described_class.new('chicago') }

  # 0.001 degrees of latitude is about 111 m.
  def request(id, lat_offset, long_offset = 0)
    { 'service_request_id' => id, 'lat' => 41.88 + lat_offset, 'long' => -87.63 + long_offset }
  end

  def nearby_ids(id, **)
    city.nearby_service_requests(city.find_service_request(id), **).map { |sr, _| sr.service_request_id }
  end

  before do
    write_city_data('chicago', service_requests: [
                      request('origin', 0), request('far', 0.003), request('near', 0.001), request('east', 0, 0.002),
                      request('outside', 0.006), { 'service_request_id' => 'none' }, request('zero', -41.88, 87.63)
                    ])
  end

  it 'returns other requests in the radius, closest first, with distances' do
    expect(nearby_ids('origin')).to eq %w[near east far]
    distance = city.nearby_service_requests(city.find_service_request('origin')).first.last
    expect(distance).to be_within(1).of(111)
  end

  it 'respects the radius and the limit' do
    expect(nearby_ids('origin', radius_meters: 200)).to eq %w[near east]
    expect(nearby_ids('origin', limit: 1)).to eq %w[near]
  end

  it 'finds requests in neighboring grid cells' do
    expect(nearby_ids('outside', radius_meters: 400)).to eq %w[far]
  end

  it 'is empty for a request without coordinates' do
    expect(nearby_ids('none')).to be_empty
    expect(nearby_ids('zero')).to be_empty
  end
end
