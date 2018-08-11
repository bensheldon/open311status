require 'rails_helper'

RSpec.describe City, type: :model do
  let(:city) { FactoryBot.create :city }

  it 'has a valid factory' do
    expect(city).to be_valid
  end

  describe 'cities.yml' do
    it 'is mounted at Rails.application.config.cities' do
      expect(Rails.configuration.cities).to be_a Hash
      expect(Rails.configuration.cities.keys.size).to be > 2
    end
  end

  describe '.load!' do
    it 'creates city records in the database' do
      allow(Rails.configuration).to receive(:cities).and_return({ test: { }})

      expect { described_class.load! }.to change(City, :count).from(0).to(1)
    end
  end

  describe '#configuration' do
    let(:city) { City.instance('san_francisco') }

    it 'stores properties on the class' do
      expect(city.configuration.name).to eq('San Francisco, CA')
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

  describe '#uptime_percent' do
    context 'service_list' do
      it 'calculates uptime' do
        FactoryBot.create :status, request_name: 'service_list', city: city, http_code: 500, created_at: 37.minutes.ago
        FactoryBot.create :status, request_name: 'service_list', city: city, http_code: 500, created_at: 27.minutes.ago

        expect(city.uptime_percent('service_list')).to be_within(0.1).of(99.30)
      end
    end

    context 'service_requests' do
      it 'calculates uptime' do
        FactoryBot.create :status, request_name: 'service_requests', city: city, http_code: 500, created_at: 37.minutes.ago
        FactoryBot.create :status, request_name: 'service_requests', city: city, http_code: 500, created_at: 27.minutes.ago

        expect(city.uptime_percent('service_requests')).to be_within(0.1).of(99.30)
      end
    end
  end
end
