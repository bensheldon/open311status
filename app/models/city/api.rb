# frozen_string_literal: true

require 'open311'
require 'hashie'

class City
  class Api
    attr_reader :city

    BACKFILL_INITIAL_INTERVAL = 1.day
    BACKFILL_GROWTH_RATE = 1.1
    BACKFILL_SHRINK_RATE = 0.5
    DEFAULT_REQUESTS_LIMIT = 50

    def initialize(city)
      @city = city
    end

    def open311
      @_open311 ||= begin
        api_options = { endpoint: city.endpoint }
        api_options[:jurisdiction] = city.jurisdiction if city.jurisdiction
        api_options[:headers] = city.headers if city.headers
        api_options[:format] = city.format if city.format

        ::Open311::Client.new(api_options)
      end
    end

    def services_url
      url_for('services.xml')
    end

    def requests_url
      url_for('requests.xml')
    end

    # Fetches the service list; replaces stored definitions on success.
    def fetch_service_list
      data, status = Status::Telemetry.process('service_list', city:) { open311.service_list }
      city.service_definitions = normalize(data) if status.success?
      city.service_definitions
    end

    # Fetches service requests since the newest one already stored and merges them in.
    def fetch_service_requests
      start_datetime = [city.latest_requested_datetime, City::SERVICE_REQUEST_RETENTION.ago].compact.max
      data, status = Status::Telemetry.process('service_requests', city:) do
        open311.service_requests(**date_params(start_datetime))
      end
      return [] unless status.success?

      merge_requests(data)
    end

    # Walks the retention window in date ranges, shrinking the range when a
    # response hits the endpoint's page limit and growing it otherwise, so that
    # requests beyond a single page are captured. Does not record statuses.
    def backfill_service_requests(start_at: City::SERVICE_REQUEST_RETENTION.ago, end_at: Time.current)
      limit = city.requests_limit || DEFAULT_REQUESTS_LIMIT
      interval = BACKFILL_INITIAL_INTERVAL.to_f
      cursor = start_at
      total = 0

      while cursor < end_at
        range_end = [cursor + interval, end_at].min
        requests = merge_requests(open311.service_requests(**date_params(cursor, range_end)))

        if requests.size >= limit && interval > 1
          interval *= BACKFILL_SHRINK_RATE # possibly truncated; retry a smaller range
        else
          total += requests.size
          cursor = range_end
          interval *= BACKFILL_GROWTH_RATE
        end
      end

      total
    end

    private

    def date_params(start_datetime, end_datetime = nil)
      params = { start_date: format_date(start_datetime) }
      params[:end_date] = format_date(end_datetime) if end_datetime
      params
    end

    def format_date(time)
      date = time.utc.xmlschema
      city.requests_omit_timezone ? date.chomp('Z') : date
    end

    def merge_requests(data)
      requests = normalize(data).select { |r| r['service_request_id'].present? }
      city.merge_service_requests(requests)
      requests
    end

    def url_for(file)
      uri = URI.parse "#{city.endpoint}#{file}"
      uri.query = URI.encode_www_form jurisdiction_id: city.jurisdiction if city.jurisdiction.present?
      uri.to_s
    end

    # Converts Hashie::Mash responses into plain hashes.
    def normalize(data)
      data = [data] if data.is_a?(Hash)
      JSON.parse(Array(data).to_json)
    end
  end
end
