# frozen_string_literal: true

# == Schema Information
#
# Table name: service_requests
#
#  id                 :bigint           not null, primary key
#  geometry           :geography        geometry, 4326
#  raw_data           :json
#  requested_datetime :datetime
#  status             :string
#  updated_datetime   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  city_id            :bigint
#  service_request_id :string
#
# Indexes
#
#  index_service_requests_on_city_id                         (city_id)
#  index_service_requests_on_city_id_and_created_at_and_id   (city_id,created_at,id)
#  index_service_requests_on_city_id_and_requested_datetime  (city_id,requested_datetime DESC NULLS LAST)
#  index_service_requests_on_city_id_and_service_request_id  (city_id,service_request_id) UNIQUE
#  index_service_requests_on_created_at                      (created_at)
#  index_service_requests_on_geometry                        (geometry) USING gist
#  index_service_requests_on_requested_datetime              (requested_datetime)
#  index_service_requests_on_status                          (status)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id) ON DELETE => cascade
#
require 'rails_helper'

RSpec.describe ServiceRequest do
  it 'has a valid factory' do
    expect(create(:service_request)).to be_valid
  end

  describe '#raw_data=' do
    let(:json) { JSON.parse(service_requests_json).first }
    let(:sr) { described_class.new raw_data: json }

    it 'extracts :service_request_id' do
      expect(sr.service_request_id).to eq json['service_request_id']
    end

    it 'extracts :status' do
      expect(sr.status).to eq json['status']
    end

    it 'extracts :requested_datetime' do
      expect(sr.requested_datetime).to eq DateTime.iso8601 json['requested_datetime']
    end

    it 'extracts :updated_datetime' do
      expect(sr.updated_datetime).to eq DateTime.iso8601 json['updated_datetime']
    end

    it 'extracts a point' do
      expect(sr.geometry.lat).to eq json['lat']
      expect(sr.geometry.lon).to eq json['long']
    end
  end

  describe '#slug' do
    let(:service_request) { create(:service_request) }

    it 'sluggifies the description' do
      service_request.raw_data['description'] = 'Something happened.'
      expect(service_request.slug).to eq 'something-happened'
    end

    context 'when description is nil' do
      specify do
        service_request.raw_data['description'] = nil
        expect(service_request.slug).to eq ''
      end
    end
  end
end
