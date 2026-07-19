# frozen_string_literal: true

class RefreshJob < ApplicationJob
  class OnFinishJob < ApplicationJob
    def perform(_batch, _context)
      GlobalIndex.refresh
    end
  end

  def perform
    GoodJob::Batch.enqueue(self, on_finish: OnFinishJob) do
      City.find_each do |city|
        FetchServiceRequestsJob.perform_later(city)
        FetchServiceListJob.perform_later(city)
      end
    end
  end
end
