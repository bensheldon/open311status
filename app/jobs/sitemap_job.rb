# frozen_string_literal: true

class SitemapJob < ApplicationJob
  def perform
    Rails.application.load_tasks
    Rake::Task['sitemap:refresh'].invoke
  end
end
