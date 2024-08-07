# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
rails_environment = ENV.fetch("RAILS_ENV") { "development" }
environment rails_environment

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers_count = ENV.fetch("WEB_CONCURRENCY") { 0 }.to_i
workers workers_count

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
preload_app!

if workers_count > 0
  before_fork do
    GoodJob.shutdown
  end

  on_worker_boot do
    GoodJob.restart
  end

  on_worker_shutdown do
    GoodJob.shutdown
  end
end

MAIN_PID = Process.pid
at_exit do
  GoodJob.shutdown if Process.pid == MAIN_PID
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
