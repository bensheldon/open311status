RSpec.describe FetchServiceRequestsRecursivelyJob do
  let(:city) { City.instance(:chicago) }

  describe '#perform' do
    it 'fetches service requests' do
      api_double = instance_double City::Api, fetch_service_requests: []
      allow(City::Api).to receive(:new).with(city).and_return(api_double)

      described_class.new.perform(city, 2.days.ago, Time.current)

      expect(api_double).to have_received(:fetch_service_requests).once
    end
  end
end