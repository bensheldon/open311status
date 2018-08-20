class FetchServiceRequestsRecursivelyJob < ApplicationJob
  INTERVAL = 1.day

  def perform(city, start_date = 7.days.ago, end_date = Time.current)
    start_date = start_date.to_datetime
    end_date = end_date.to_datetime

    Raven.extra_context(city: city.slug)
    api = City::Api.new city

    relative_end_date = start_date + INTERVAL

    Rails.logger.info "Collecting service requests from #{ city.name }, between #{start_date} and #{relative_end_date} (until #{end_date})"
    new_service_requests = api.fetch_service_requests(start_date, relative_end_date, collect_telemetry: false)
    Rails.logger.info "#{ city.name } had #{ new_service_requests.size } new service requests"

    relative_start_date = if new_service_requests.size.zero?
                            relative_end_date
                          else
                            new_service_requests.map(&:requested_datetime).max
                          end

    if relative_end_date < end_date
      if ENV['ASYNC'].present?
        self.class.perform_later(city, relative_start_date.to_json, end_date.to_json)
      else
        self.class.perform_now(city, relative_start_date.to_json, end_date.to_json)
      end
    end
  end
end
