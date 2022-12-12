# frozen_string_literal: true

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
