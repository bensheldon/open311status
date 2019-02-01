# frozen_string_literal: true

RSpec.describe FetchServiceRequestsJob do
  let(:city) { City.instance(:chicago) }

  describe '#perform' do
    it 'fetches service requests' do
      api_double = instance_double City::Api, fetch_service_requests: []
      allow(City::Api).to receive(:new).with(city).and_return(api_double)

      described_class.new.perform(city)

      expect(api_double).to have_received(:fetch_service_requests)
    end
  end
end
