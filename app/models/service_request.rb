# frozen_string_literal: true

class ServiceRequest
  SLUG_SIZE = 100

  attr_reader :city, :raw_data

  def initialize(city, raw_data)
    @city = city
    @raw_data = raw_data.to_h
  end

  def service_request_id
    raw_data['service_request_id']&.to_s
  end

  def status
    raw_data['status']
  end

  def requested_datetime
    return @_requested_datetime if defined?(@_requested_datetime)

    @_requested_datetime = parse_time(raw_data['requested_datetime'])
  end

  def updated_datetime
    parse_time(raw_data['updated_datetime'])
  end

  def slug
    @_slug ||= begin
      description = raw_data['description'].presence || ''
      slug = description.gsub(/(-|_)/, ' ').squish.encode.to_slug.normalize.to_s.downcase
      slug = slug[0, SLUG_SIZE].gsub(/-$/, '') if slug.size > SLUG_SIZE
      slug
    end
  end

  def media_url
    url = raw_data['media_url']
    return if url.blank?

    uri = URI.parse(url)
    uri.scheme = 'https'
    uri.host = URI.parse(city.endpoint).host if uri.host.blank?
    uri.to_s
  rescue URI::InvalidURIError
    nil
  end

  private

  def parse_time(value)
    return if value.blank?

    Time.zone.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
