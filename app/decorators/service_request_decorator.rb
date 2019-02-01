# frozen_string_literal: true

class ServiceRequestDecorator < Draper::Decorator
  delegate_all

  def media_url
    url = raw_data['media_url']
    return if url.blank?

    uri = URI.parse(url)
    uri.scheme = 'https'
    if uri.host.blank?
      city_uri = URI.parse city.endpoint
      uri.host = city_uri.host
    end
    uri.to_s
  end
end
