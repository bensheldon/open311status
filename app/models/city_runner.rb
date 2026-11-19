# frozen_string_literal: true

# Runs a block for each city concurrently as Concurrent::Promises futures on a fixed pool of threads.
# An error in one city is logged and doesn't stop the others.
class CityRunner
  def initialize(slugs: Rails.configuration.cities.keys, threads: 10, logger: Rails.logger)
    @slugs = slugs
    @threads = threads
    @logger = logger
  end

  def each(&)
    pool = Concurrent::FixedThreadPool.new(@threads)
    futures = @slugs.map do |slug|
      Concurrent::Promises.future_on(pool, slug) { |s| yield(City.new(s)) }
                          .rescue { |e| @logger.error "#{slug}: #{e.class}: #{e.message}" }
    end
    Concurrent::Promises.zip(*futures).wait
  ensure
    pool&.shutdown
    pool&.wait_for_termination
  end
end
