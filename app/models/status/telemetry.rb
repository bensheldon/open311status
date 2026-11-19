# frozen_string_literal: true

require 'open311'
require 'timeout'

class Status
  module Telemetry
    TIMEOUT = 60 # seconds; the open311 gem doesn't expose Faraday timeouts

    HTTP_CODES = {
      'Open311::BadRequest' => 400,
      'Open311::Unauthorized' => 401,
      'Open311::Forbidden' => 403,
      'Open311::NotFound' => 404,
      'Open311::NotAcceptable' => 406,
      'Open311::InternalServerError' => 500,
      'Open311::BadGateway' => 502,
      'Open311::ServiceUnavailable' => 503,
    }.freeze

    # Yields, records a Status on the city, and returns [response, status].
    def self.process(request_name, city:, &)
      status = Status.new(request_name:)
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      response = nil

      begin
        response = with_timeout(&)
        status.http_code = 200
      rescue StandardError => e
        record_error(status, e)
      end

      status.duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).to_i
      city.add_status(status)
      [response, status]
    end

    # Runs an API request, raising Timeout::Error if it takes longer than TIMEOUT.
    def self.with_timeout(&)
      Timeout.timeout(TIMEOUT, &)
    end

    # Marks the status as failed: with the HTTP code for Open311 errors, or the
    # error message for anything else.
    def self.record_error(status, error)
      status.http_code = HTTP_CODES[error.class.name]
      status.error_message = status.http_code ? nil : "#{error.class}: #{error}"
    end
  end
end
