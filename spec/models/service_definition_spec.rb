# == Schema Information
#
# Table name: service_definitions
#
#  id           :integer          not null, primary key
#  city_id      :integer
#  service_code :string(255)
#  raw_data     :json
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_service_definitions_on_city_id                   (city_id)
#  index_service_definitions_on_city_id_and_service_code  (city_id,service_code)
#

require 'rails_helper'

RSpec.describe ServiceDefinition, type: :model do
  it 'has a valid factory' do
    expect(FactoryGirl.create :service_definition).to be_valid
  end

  describe '#raw_data=' do
    let(:json) { JSON.parse(service_list_json).first }
    let(:sd) { ServiceDefinition.new raw_data: json }

    it 'extracts :service_code' do
      expect(sd.service_code).to eq json['service_code']
    end
  end
end
