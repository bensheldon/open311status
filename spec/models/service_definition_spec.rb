# frozen_string_literal: true

# == Schema Information
#
# Table name: service_definitions
#
#  id           :bigint           not null, primary key
#  raw_data     :json
#  service_code :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  city_id      :bigint
#
# Indexes
#
#  index_service_definitions_on_city_id                   (city_id)
#  index_service_definitions_on_city_id_and_service_code  (city_id,service_code)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id) ON DELETE => cascade
#
require 'rails_helper'

RSpec.describe ServiceDefinition do
  it 'has a valid factory' do
    expect(create(:service_definition)).to be_valid
  end

  describe '#raw_data=' do
    let(:json) { JSON.parse(service_list_json).first }
    let(:sd) { described_class.new raw_data: json }

    it 'extracts :service_code' do
      expect(sd.service_code).to eq json['service_code']
    end
  end
end
