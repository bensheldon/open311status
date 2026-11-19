# frozen_string_literal: true

namespace :data do
  # Runs the block for each city slug (SLUGS=a,b to limit) across THREADS threads.
  def each_city_in_parallel
    Rails.logger = ActiveSupport::Logger.new($stdout)
    slugs = ENV['SLUGS'].present? ? ENV['SLUGS'].split(',') : Rails.configuration.cities.keys
    queue = Queue.new
    slugs.each { |slug| queue << slug }
    queue.close

    Array.new(ENV.fetch('THREADS', 10).to_i) do
      Thread.new do
        while (slug = queue.pop)
          begin
            yield City.new(slug)
          rescue StandardError => e
            Rails.logger.error "#{slug}: #{e.class}: #{e.message}"
          end
        end
      end
    end.each(&:join)
  end

  desc 'Deep backfill service requests over the retention window for all cities (or SLUGS=a,b)'
  task backfill: :environment do
    each_city_in_parallel do |city|
      count = city.api.fetch_service_requests_in_ranges.size
      Rails.logger.info "#{city.slug}: backfilled #{count} requests (#{city.service_requests.size} stored)"
    rescue City::Api::IncompleteFetchError => e
      Rails.logger.error "#{city.slug}: backfill stopped after #{e.fetched.size} requests: #{e.message}"
    ensure
      city.save # keep the requests from completed ranges
    end
  end

  desc 'Fetch service lists and service requests for all cities (or SLUGS=a,b) and write them to the data directory'
  task fetch: :environment do
    each_city_in_parallel do |city|
      definitions = city.api.fetch_service_list
      requests = city.api.fetch_service_requests
      Rails.logger.info "#{city.slug}: #{definitions.size} service definitions, #{requests.size} new/updated requests " \
                        "(list: #{city.service_list_status.title}, requests: #{city.service_requests_status.title})"
    ensure
      city.save # keep statuses and any fetched data, even after an unexpected error
    end
  end
end

namespace :data do
  desc 'Write fake data for tests into DATA_PATH: Chicago gets the service requests in spec/fixtures'
  task fake: :environment do
    fixture = ->(name) { JSON.parse(Rails.root.join("spec/fixtures/#{name}.json").read) }
    service_requests = fixture.call('service_requests').each_with_index.map do |raw, i|
      raw.merge('requested_datetime' => (i + 1).hours.ago.iso8601)
    end
    statuses = [{ 'request_name' => 'service_requests', 'created_at' => 1.hour.ago.utc.iso8601, 'http_code' => 200, 'duration_ms' => 100 }]
    DataStore.write('chicago', 'service_definitions' => fixture.call('service_list'), 'statuses' => statuses,
                               'service_requests' => service_requests)
    puts "Wrote fake data into #{DataStore.path}"
  end
end
