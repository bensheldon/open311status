GoodJob.preserve_job_records = true
GoodJob.retry_on_unhandled_error = false
GoodJob.on_thread_error = ->(exception) { Raven.capture_exception(exception) }

Rails.application.configure do
  config.good_job.cleanup_interval_seconds = 600
  config.good_job.cleanup_interval_jobs = 20
end

if Rails.env.production?
  Rails.application.configure do
    config.good_job.execution_mode = :async
  end
end

