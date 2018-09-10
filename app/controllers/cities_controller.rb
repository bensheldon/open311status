class CitiesController < ApplicationController
  def index
    cities = City.includes(:service_list_status, :service_requests_status, :service_list_status_errors, :service_request_status_errors).all.order(slug: :asc)
    @cities = CityDecorator.decorate_collection(cities)

    sr_buckets = ServiceRequest.where(city_id: @cities.pluck(:id)).group(:city_id).group_by_hour(:requested_datetime, range: 2.days.ago..Time.current).count
    sr_buckets_by_city = sr_buckets.each_with_object({}) do |(key, value), memo|
      memo[key.first] ||= {}
      memo[key.first][key.second] = value
    end
    @cities.each { |city| city.bucketed_service_requests = sr_buckets_by_city.fetch(city.id, {}) }
  end

  def show
    @city = City.find_by!(slug: params[:slug])
  end
end
