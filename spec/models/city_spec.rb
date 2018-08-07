require 'rails_helper'

RSpec.describe City, type: :model do
  let(:city) { FactoryBot.create :city }

  it 'has a valid factory' do
    expect(city).to be_valid
  end

  describe '.configuration' do
    let(:city) { Cities::Test.new }

    it 'stores properties on the class' do
      expect(city.configuration.name).to eq('Test City')
    end

    describe 'defines configuration accessors' do
      it '#name' do
        expect(city.name).to be_a String
      end

      it '#endpoint' do
        expect(city.endpoint).to be_a String
      end

      it '#jurisdiction' do
        expect(city.jurisdiction).to be_a String
      end

      it 'raises NoMethodError for undefined configuration properties' do
        expect { city.mumble_mumble }.to raise_error NoMethodError
      end
    end
  end

  describe '#service_list_status' do
    it 'returns most recent status with type=service_list' do
      FactoryBot.create :status, city: city, request_name: 'service_requests', created_at: 1.day.ago
      FactoryBot.create :status, city: city, request_name: 'service_list', created_at: 1.day.ago
      latest_status = FactoryBot.create :status, city: city, request_name: 'service_list'
      FactoryBot.create :status, city: city, request_name: 'service_requests', created_at: 2.day.ago
      FactoryBot.create :status, city: city, request_name: 'service_list', created_at: 2.day.ago

      expect(city.service_list_status).to eq latest_status
    end
  end

  describe '#service_requests_status' do
    it 'returns most recent status with type=service_list' do
      FactoryBot.create :status, city: city, request_name: 'service_requests', created_at: 1.day.ago
      FactoryBot.create :status, city: city, request_name: 'service_list', created_at: 1.day.ago
      latest_status = FactoryBot.create :status, city: city, request_name: 'service_requests'
      FactoryBot.create :status, city: city, request_name: 'service_requests', created_at: 2.day.ago
      FactoryBot.create :status, city: city, request_name: 'service_list', created_at: 2.day.ago

      expect(city.service_requests_status).to eq latest_status
    end
  end
end
