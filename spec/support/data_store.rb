# frozen_string_literal: true

module DataStoreHelpers
  def fixture_json(name)
    JSON.parse(Rails.root.join("spec/fixtures/#{name}.json").read)
  end

  # Writes a city's YAML data file, with service requests re-dated to be recent.
  def write_city_data(slug, service_requests: fixture_json('service_requests'), service_definitions: fixture_json('service_list'), statuses: nil)
    service_requests = service_requests.each_with_index.map do |raw, i|
      raw.merge('requested_datetime' => (i + 1).hours.ago.iso8601)
    end
    statuses ||= [
      { 'request_name' => 'service_list', 'created_at' => 1.hour.ago.utc.iso8601, 'http_code' => 200, 'duration_ms' => 100 },
      { 'request_name' => 'service_requests', 'created_at' => 2.hours.ago.utc.iso8601, 'http_code' => 500, 'duration_ms' => 100 },
      { 'request_name' => 'service_requests', 'created_at' => 1.hour.ago.utc.iso8601, 'http_code' => 200, 'duration_ms' => 1500 },
    ]
    DataStore.write(slug, 'service_definitions' => service_definitions, 'statuses' => statuses, 'service_requests' => service_requests)
  end
end

RSpec.configure do |config|
  config.include DataStoreHelpers

  config.around do |example|
    original = Rails.configuration.data_path
    Dir.mktmpdir do |dir|
      Rails.configuration.data_path = Pathname.new(dir)
      example.run
    ensure
      Rails.configuration.data_path = original
    end
  end
end
