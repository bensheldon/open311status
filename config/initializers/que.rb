ActiveJob::Base.queue_adapter = :que

# Logging to just these events
Que.log_formatter = proc do |data|
  next if [:job_worked, :job_unavailable].include? data[:event]
  JSON.dump(data)
end
