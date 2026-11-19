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

    # Raised when a request fails partway through fetching date ranges. The
    # requests in #fetched (from the ranges that completed) are already merged.
    class IncompleteFetchError < StandardError
      attr_reader :fetched

      def initialize(fetched, error)
        @fetched = fetched
        super("#{error.class}: #{error.message}")
      end
    end

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
    #
    # The newest stored request is the cursor for the next fetch, so requests are
    # only merged once every request up to them is known to be fetched. If the
    # first response is a full page, it may be truncated: the range is then
    # fetched again in smaller date ranges (see #fetch_service_requests_in_ranges).
    # If a range fails, the status records the error and the requests from the
    # ranges that completed are kept. Returns the requests that were fetched.
    def fetch_service_requests
      start_at = [city.latest_requested_datetime, City::SERVICE_REQUEST_RETENTION.ago].compact.max
      end_at = Time.current
      data, status = Status::Telemetry.process('service_requests', city:) do
        open311.service_requests(**date_params(start_at))
      end
      return [] unless status.success?

      requests = normalize_requests(data)
      if requests.size >= requests_limit
        begin
          return fetch_service_requests_in_ranges(start_at:, end_at:)
        rescue IncompleteFetchError => e
          Status::Telemetry.record_error(status, e.cause)
          return e.fetched
        end
      end

      city.merge_service_requests(requests)
      requests
    end

    # Fetches every service request between start_at and end_at, oldest range
    # first. A response that fills a page may be truncated, so it is discarded and
    # the range is halved; otherwise the requests are merged and the next range
    # grows. Merging only complete ranges, in order, keeps the cursor safe if a
    # request fails partway through; then it raises IncompleteFetchError. Each
    # request has the same timeout as a status check. Does not record statuses.
    # Returns the requests that were fetched.
    def fetch_service_requests_in_ranges(start_at: City::SERVICE_REQUEST_RETENTION.ago, end_at: Time.current)
      interval = BACKFILL_INITIAL_INTERVAL.to_f
      cursor = start_at
      fetched = []

      while cursor < end_at
        range_end = [cursor + interval, end_at].min
        begin
          data = Status::Telemetry.with_timeout { open311.service_requests(**date_params(cursor, range_end)) }
        rescue StandardError => e
          raise IncompleteFetchError.new(fetched, e)
        end
        requests = normalize_requests(data)

        if requests.size >= requests_limit && interval > 1
          interval *= BACKFILL_SHRINK_RATE
        else
          city.merge_service_requests(requests)
          fetched.concat(requests)
          cursor = range_end
          interval *= BACKFILL_GROWTH_RATE
        end
      end

      fetched
    end

    private

    def date_params(start_datetime, end_datetime = nil)
      params = { start_date: format_date(start_datetime) }
      params[:end_date] = format_date(end_datetime) if end_datetime
      params
    end

    def format_date(time)
      time.utc.xmlschema
    end

    def normalize_requests(data)
      normalize(data).select { |r| r['service_request_id'].present? }
    end

    def requests_limit
      city.requests_limit || DEFAULT_REQUESTS_LIMIT
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
