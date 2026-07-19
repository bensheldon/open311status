# frozen_string_literal: true
require 'rails_helper'

RSpec.describe RefreshJob do
  let!(:city) { City.instance('chicago') }

  describe '#perform' do
    it 'enqueues a bunch of jobs for each city, then refreshes the global index once they finish' do
      api_double = instance_double City::Api, fetch_service_requests: [], fetch_service_list: []
      allow(City::Api).to receive(:new).with(city).and_return(api_double)
      allow(GlobalIndex).to receive(:refresh)

      described_class.perform_later

      expect(api_double).to have_received(:fetch_service_requests)
      expect(api_double).to have_received(:fetch_service_list)
      expect(GlobalIndex).to have_received(:refresh)
    end

    it 'adds itself and all the per-city jobs to the same batch' do
      api_double = instance_double City::Api, fetch_service_requests: [], fetch_service_list: []
      allow(City::Api).to receive(:new).with(city).and_return(api_double)
      allow(GlobalIndex).to receive(:refresh)

      described_class.perform_later

      batch_id = GoodJob::Job.find_by!(job_class: 'RefreshJob').batch_id
      expect(batch_id).to be_present
      expect(GoodJob::Job.where(job_class: 'FetchServiceRequestsJob').pluck(:batch_id)).to all(eq(batch_id))
      expect(GoodJob::Job.where(job_class: 'FetchServiceListJob').pluck(:batch_id)).to all(eq(batch_id))
    end
  end
end
