require 'rails_helper'

RSpec.describe City::Api do
  let(:city) { Cities::Toronto.instance }
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
  end
end