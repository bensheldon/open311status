require 'rails_helper'

RSpec.describe ServiceRequest, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create :service_request).to be_valid
  end

  it 'has an STI city relation' do
    city = FactoryGirl.create :test_city
    sr = city.service_requests.new
    sr.save!

    expect(sr.city).to be_instance_of Cities::TestCity
  end

  describe '#raw_data=' do
    let(:json) { JSON.parse(service_requests_json).first }

    it 'denormalizes :service_request_id' do
      sr = ServiceRequest.new raw_data: json
      expect(sr.service_request_id).to eq json['service_request_id']
    end

    it 'denormalizes :status' do
      sr = ServiceRequest.new raw_data: json
      expect(sr.status).to eq json['status']
    end
  end
end
