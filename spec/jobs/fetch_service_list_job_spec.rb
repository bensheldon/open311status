RSpec.describe FetchServiceListJob do
  let(:city) { Cities::Chicago.instance }

  describe '#perform' do
    it 'fetches service list' do
      api_double = instance_double City::Api, fetch_service_list: []
      allow(City::Api).to receive(:new).with(city).and_return(api_double)

      described_class.new.perform(city)

      expect(api_double).to have_received(:fetch_service_list)
    end
  end
end