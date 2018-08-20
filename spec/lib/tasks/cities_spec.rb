require 'rails_helper'

RSpec.describe "cities:cleanup", type: :rake do
  include_context "rake"

  let(:city) { City.instance('san_francisco')}

  it 'deletes old service requests and statuses' do
    service_requests = FactoryBot.create_list :service_request, 2, city: city, created_at: 3.days.ago
    statuses = FactoryBot.create_list :status, 2, city: city, created_at: 3.days.ago

    expect {
      task.invoke
    }.to change { ServiceRequest.count }.from(2).to(0)
        .and change { Status.count }.from(2).to(0)
  end
end

RSpec.describe "cities:all_service_requests", type: :rake do
  include_context "rake"

  let(:city) { City.instance('san_francisco')}

  context 'with START_AT and END_AT' do
    around do |example|
      Timecop.freeze do
        with_modified_env(START_AT: '2018/7/1', END_AT: '2018/7/31') do
          example.run
        end
      end
    end

    it 'runs FetchServiceRequestsRecursively' do
      allow(FetchServiceRequestsRecursivelyJob).to receive(:perform_now)
      task.invoke(city.slug)
      expect(FetchServiceRequestsRecursivelyJob).to have_received(:perform_now).with(
        city,
        kind_of(String),
        kind_of(String)
      )
    end
  end
end