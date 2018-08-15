require 'rails_helper'

RSpec.describe City::Api do
  let(:city) { City.instance('toronto')}
  subject(:api) { described_class.new city }

  describe '#fetch_service_list' do
    before do
      stub_request(:get, 'https://secure.toronto.ca/webwizard/ws/services.xml?jurisdiction_id=toronto.ca')
          .to_return(status: 200, body: file_fixture("services_giessen.xml").read, headers: {})
    end

    specify do
      expect {
        api.fetch_service_list
      }.to change { ServiceDefinition.count }.from(0).to(8)
    end
  end

  describe '#fetch_service_requests' do
    context 'single service request' do
      before do
        stub_request(:get, %r{https://secure\.toronto\.ca/webwizard/ws/requests\.xml\?jurisdiction_id=toronto\.ca&start_date=.*})
            .to_return(status: 200, body: file_fixture("requests_toronto_single.xml").read, headers: {})
      end

      specify do
        expect {
          api.fetch_service_requests
        }.to change { ServiceRequest.count }.from(0).to(1)
      end
    end

    context 'multiple service requests' do
      before do
        stub_request(:get, %r{https://secure\.toronto\.ca/webwizard/ws/requests\.xml\?jurisdiction_id=toronto\.ca&start_date=.*})
            .to_return(status: 200, body: file_fixture("requests_toronto_multi.xml").read, headers: {})
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
      expect(api.services_url).to eq 'https://secure.toronto.ca/webwizard/ws/services.xml?jurisdiction_id=toronto.ca'
    end
  end

  describe '#requests_url' do
    it 'formats correct URL' do
      expect(api.requests_url).to eq 'https://secure.toronto.ca/webwizard/ws/requests.xml?jurisdiction_id=toronto.ca'
    end
  end
end