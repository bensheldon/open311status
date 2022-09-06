Rails.application.configure do
  config.good_job.on_thread_error = ->(exception) { Raven.capture_exception(exception) }

  config.good_job.preserve_job_records = true
  config.good_job.retry_on_unhandled_error = false
  config.good_job.cleanup_interval_seconds = 600
  config.good_job.cleanup_interval_jobs = 20

  if Rails.env.production?
    config.good_job.execution_mode = :async
    config.good_job.cron = {
      refresh: {
        cron: '*/10 * * * *',
        class: 'RefreshJob',
        description: "Update open311 statuses",
      },
      sitemap: {
        cron: '0 7 * * *',
        class: 'SitemapJob',
        description: "Update Sitemap",
      },
    }

    GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |provided_username, provided_password|
      username, password = ENV.fetch('GOOD_JOB_AUTH', '').split(':')
      return false if username.blank? || password.blank?

      ActiveSupport::SecurityUtils.secure_compare(username, provided_username) &&
        ActiveSupport::SecurityUtils.secure_compare(password, provided_password)
    end
  end
end
