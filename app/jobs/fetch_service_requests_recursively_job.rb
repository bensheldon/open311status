class FetchServiceRequestsRecursivelyJob < ApplicationJob
  INITIAL_INTERVAL = 1.day.to_i
  GROWTH_RATE = 1.1
  SHRINK_RATE = 0.5

  def perform(city, start_at = 7.days.ago, end_at = Time.current, interval = INITIAL_INTERVAL)
    interval = interval.positive? ? interval.second : 1.second
    api_limit = 50

    Raven.extra_context(city: city.slug)

    start_date = start_at.to_datetime
    end_date = end_at.to_datetime

    relative_end_date = start_date + interval

    if relative_end_date >= end_date || relative_end_date > Time.current
      # we're done
      return
    end

    api = City::Api.new city

    Rails.logger.info "Collecting service requests from #{ city.name }, between #{start_date} and #{relative_end_date} (until #{end_date})"
    new_service_requests = api.fetch_service_requests(start_date, relative_end_date, collect_telemetry: false)
    Rails.logger.info "#{ city.name } had #{ new_service_requests.size } new service requests between #{start_date} and #{relative_end_date} (until #{end_date}) with interval #{interval}"

    if new_service_requests.size < api_limit
      return self.class.perform_later(city, relative_end_date.to_json, end_date.to_json, (interval * GROWTH_RATE).to_f.round(2))
    elsif new_service_requests.size == api_limit
      return self.class.perform_later(city, start_date.to_json, end_date.to_json, (interval * SHRINK_RATE).to_f.round(2))
    else
      Rails.logger.warn "API LIMIT for #{city.slug} is too small. Expected: #{api_limit}. Actual: #{new_service_requests.size}"
    end
  end
end
