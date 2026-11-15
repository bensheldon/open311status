# frozen_string_literal: true

class Status
  REQUEST_NAMES = %w[service_list service_requests].freeze

  attr_accessor :request_name, :created_at, :http_code, :duration_ms, :error_message

  def initialize(request_name:, created_at: Time.current, http_code: nil, duration_ms: nil, error_message: nil)
    raise ArgumentError, "Invalid request_name: #{request_name}" unless REQUEST_NAMES.include?(request_name)

    @request_name = request_name
    @created_at = created_at.is_a?(String) ? Time.zone.parse(created_at) : created_at
    @http_code = http_code
    @duration_ms = duration_ms
    @error_message = error_message
  end

  def to_h
    {
      'request_name' => request_name,
      'created_at' => created_at.utc.iso8601,
      'http_code' => http_code,
      'duration_ms' => duration_ms,
      'error_message' => error_message,
    }.compact
  end

  def success?
    http_code == 200
  end

  def quality
    if !success?
      :error
    elsif duration_ms.to_i > 999
      :slow
    else
      :success
    end
  end

  def title
    { success: 'Okay', slow: 'Slow', error: 'Error' }[quality]
  end

  def description
    case quality
    when :success then "Server responded in #{duration_ms} ms"
    when :slow then "Server slow response of #{duration_ms} ms"
    else
      if http_code.present?
        "Server responded with #{http_code} after #{duration_ms} ms"
      else
        "Error processing response after #{duration_ms} ms: '#{error_message}'"
      end
    end
  end

  def label_class
    { success: 'success', slow: 'warning', error: 'danger' }[quality]
  end
end
