# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ServiceRequestDecorator, type: :decorator do
  subject(:decorated) { described_class.decorate service_request }

  let(:city) { City.instance(:chicago) }
  let(:service_request) { create(:service_request) }

  describe '#media_url' do
    it 'is nil when invalid' do
      decorated.raw_data['media_url'] = false
      expect(decorated.media_url).to be_nil
    end

    it 'upgrades to https' do
      decorated.raw_data['media_url'] = "http://example.com/something.png?key=value"
      expect(decorated.media_url).to eq "https://example.com/something.png?key=value"
    end

    it 'appends the host domain' do
      decorated.raw_data['media_url'] = "/something.png?key=value"
      expect(decorated.media_url).to eq "https://311api.cityofchicago.org/something.png?key=value"
    end
  end
end
