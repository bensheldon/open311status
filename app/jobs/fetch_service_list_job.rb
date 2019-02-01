# frozen_string_literal: true

class FetchServiceListJob < ApplicationJob
  def perform(city)
    Raven.extra_context(city: city.slug)
    Rails.logger.info "Collecting service definitions list from #{city.name}"
    api = City::Api.new city
    new_service_list = api.fetch_service_list
    Rails.logger.info "#{city.name} has #{new_service_list.size} service definitions"

    CityBroadcastJob.perform_now(city)
  end
end
