# frozen_string_literal: true
require 'rails_helper'

RSpec.describe RefreshJob do
  let!(:city) { City.instance('chicago') }

  describe '#perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'enqueues a bunch of jobs for each city' do
      expect { described_class.perform_now }
        .to have_enqueued_job(FetchServiceRequestsJob).with(city)
        .and have_enqueued_job(FetchServiceListJob).with(city)
    end
  end
end
