# frozen_string_literal: true

require 'open311'

class Status
  class Telemetry
    attr_accessor :request_name, :city, :status

    def self.process(request_name, options = {}, &block)
      new(request_name, options).process(&block)
    end

    def initialize(request_name, options = {})
      self.request_name = request_name
      self.city = options.fetch :city

      self.status = city.statuses.new request_name: request_name
    end

    def process
      response = nil
      start = Time.current

      begin
        response = yield
        status.http_code = 200
      rescue Open311::Error => e
        status.http_code = open311_error_to_http_code(e)
      rescue StandardError => e
        status.error_message = "#{e.class}: #{e}"
      end

      status.duration_ms = ((Time.current - start) * 1000).to_i
      status.save!

      response
    end

    def open311_error_to_http_code(exception)
      case exception
      when Open311::BadRequest
        400
      when Open311::Unauthorized
        401
      when Open311::Forbidden
        403
      when Open311::NotFound
        404
      when Open311::NotAcceptable
        406
      when Open311::InternalServerError
        500
      when Open311::BadGateway
        502
      when Open311::ServiceUnavailable
        503
      else
        raise exception
      end
    end
  end
end
