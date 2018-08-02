# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  slug       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_cities_on_slug  (slug) UNIQUE
#

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
end
