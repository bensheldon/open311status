require 'rails_helper'

RSpec.describe City::Api do
  let(:city) { City.instance('dc')}
  subject(:api) { described_class.new city }

  describe '#fetch_service_list' do
    before do
      stub_request(:get, "http://app.311.dc.gov/CWI/Open311/v2/services.xml?jurisdiction_id=dc.gov")
          .to_return(status: 200, body: file_fixture("services_giessen.xml").read, headers: {})
    end

    specify do
      expect {
        api.fetch_service_list
      }.to change { ServiceDefinition.count }.from(0).to(8)
    end
  end

  describe '#fetch_service_requests' do
    it 'Sets timezone to "Z" when passing through start and end times' do
      open311_double = double(Open311, service_requests: [])
      allow(api).to receive(:open311).and_return(open311_double)

      start_at = "2018/01/01".to_datetime
      end_at = "2018/01/02".to_datetime

      result = api.fetch_service_requests(start_at, end_at)

      expect(open311_double).to have_received(:service_requests).with(start_date: "2018-01-01T00:00:00Z", end_date: "2018-01-02T00:00:00Z")
    end

    context 'single service request' do
      before do
        stub_request(:get, %r{http://app\.311\.dc\.gov/CWI/Open311/v2/requests\.xml\?jurisdiction_id=dc\.gov&start_date=.*})
            .to_return(status: 200, body: file_fixture("requests_single.xml").read, headers: {})
      end

      specify do
        expect {
          api.fetch_service_requests
        }.to change { ServiceRequest.count }.from(0).to(1)
      end
    end

    context 'multiple service requests' do
      before do
        stub_request(:get, %r{http://app\.311\.dc\.gov/CWI/Open311/v2/requests\.xml\?jurisdiction_id=dc\.gov&start_date=.*})
            .to_return(status: 200, body: file_fixture("requests_many.xml").read, headers: {})
      end

      specify do
        expect {
          api.fetch_service_requests
        }.to change { ServiceRequest.count }.from(0).to(2)
      end
    end

    context 'service request without service_request_id' do
      specify 'it skips them' do
        require 'hashie'

        service_request = Hashie::Mash.new({
                                               service_request_id: nil
                                           })

        open311_double = double(Open311, service_requests: [service_request])
        allow(api).to receive(:open311).and_return(open311_double)

        result = api.fetch_service_requests
        expect(result).to eq []
      end
    end
  end

  describe '#services_url' do
    it 'formats correct URL' do
      expect(api.services_url).to eq "http://app.311.dc.gov/CWI/Open311/v2/services.xml?jurisdiction_id=dc.gov"
    end
  end

  describe '#requests_url' do
    it 'formats correct URL' do
      expect(api.requests_url).to eq "http://app.311.dc.gov/CWI/Open311/v2/requests.xml?jurisdiction_id=dc.gov"
    end
  end
end