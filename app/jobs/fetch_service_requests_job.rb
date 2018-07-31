class FetchServiceRequestsJob < ApplicationJob
  def perform(city)
    Raven.extra_context(city: city.slug)
    Rails.logger.info "Collecting service requests from #{ city.name }"
    api = City::Api.new city
    new_service_requests = api.fetch_service_requests
    Rails.logger.info "#{ city.name } had #{ new_service_requests.size } new service requests"
  end
end
