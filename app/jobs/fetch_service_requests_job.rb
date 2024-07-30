# frozen_string_literal: true

class FetchServiceRequestsJob < ApplicationJob
  def perform(city)
    Sentry.set_context(:city, { slug: city.slug })
    Rails.logger.info "Collecting service requests from #{city.name}"
    api = City::Api.new city
    new_service_requests = api.fetch_service_requests
    Rails.logger.info "#{city.name} had #{new_service_requests.size} new service requests"

    CityBroadcastJob.perform_now(city)
  end
end
