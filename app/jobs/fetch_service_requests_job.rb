class FetchServiceRequestsJob < ApplicationJob
  def perform(city)
    api = City::Api.new city
    Rails.logger.info "Collecting service requests from #{ city.name }"
    new_service_requests = api.fetch_service_requests
    Rails.logger.info "#{ city.name } had #{ new_service_requests.size } new service requests"
  end
end