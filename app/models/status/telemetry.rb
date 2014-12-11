require 'open311'

class Status
  class Telemetry
    attr_accessor :request_name, :city, :status

    def self.process(request_name, options = {})
      new(request_name, options).process { yield }
    end

    def initialize(request_name, options = {})
      self.request_name = request_name
      self.city = options.fetch :city

      self.status = city.statuses.new request_name: request_name
    end

    def process
      response = nil
      start = Time.now

      begin
        response = yield
        status.http_code = 200
      rescue Open311::Error => error
        status.http_code = open311_error_to_http_code(error)
      rescue Timeout::Error
        status.http_code = 0
      end

      status.duration_ms = ((Time.now - start) * 1000).to_i
      status.save!

      response
    end

    def open311_error_to_http_code(exception)
      case exeption
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
