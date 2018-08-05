require 'rails_helper'

RSpec.describe ServiceDefinition, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.create :service_definition).to be_valid
  end

  describe '#raw_data=' do
    let(:json) { JSON.parse(service_list_json).first }
    let(:sd) { ServiceDefinition.new raw_data: json }

    it 'extracts :service_code' do
      expect(sd.service_code).to eq json['service_code']
    end
  end
end
