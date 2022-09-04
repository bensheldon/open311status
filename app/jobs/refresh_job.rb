# frozen_string_literal: true

class RefreshJob < ApplicationJob
  def perform
    Rails.application.load_tasks
    Rake::Task['cities:service_requests'].invoke
    Rake::Task['cities:service_list'].invoke
    Rake::Task['db:views:refresh'].reenable
  end
end
