# frozen_string_literal: true

class RefreshJob < ApplicationJob
  def perform
    City.all.each do |city|
      FetchServiceRequestsJob.perform_later(city)
      FetchServiceListJob.perform_later(city)
    end
    GlobalIndex.refresh # TODO: this should ideally happen after all the jobs are done
  end
end
