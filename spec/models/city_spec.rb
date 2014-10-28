require 'rails_helper'

RSpec.describe City, type: :model do
  it 'has a valid factory' do
    FactoryGirl.create :test_city
  end

  describe '.configuration' do
    let(:city) { Cities::TestCity.new }

    it 'stores properties on the class' do
      expect(city.configuration.name).to eq('Test')
    end

    describe 'defines configuration accessors' do
      it '#name' do
        expect(city.name).to eq('Test')
      end

      it '#state' do
        expect(city.state).to eq('TS')
      end

      it '#jurisdiction' do
        expect(city.jurisdiction).to eq('test.org')
      end

      it '#endpoint' do
        expect(city.endpoint).to eq('http://test.org/open311')
      end

      it 'raises NoMethodError for undefined configuration properties' do
        expect { city.mumble_mumble }.to raise_error NoMethodError
      end
    end

  end

  pending "add some examples to (or delete) #{__FILE__}"
end
