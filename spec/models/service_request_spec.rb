require 'rails_helper'

RSpec.describe ServiceRequest, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.create :service_request).to be_valid
  end

  describe '#raw_data=' do
    let(:json) { JSON.parse(service_requests_json).first }
    let(:sr) { ServiceRequest.new raw_data: json }

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
  end
end
