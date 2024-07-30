# frozen_string_literal: true

class SitemapsController < ApplicationController
  def index
    @cities = City.all

    respond_to do |format|
      format.xml
    end
  end

  def city_index
    @city = City.find_by!(slug: params[:slug])

    oldest_service_request = @city.service_requests.order(:created_at, :id).limit(1).pick(:created_at)&.to_date || Date.current
    @dates = oldest_service_request..Date.current

    respond_to do |format|
      format.xml
    end
  end

  def city_day
    @city = City.find_by!(slug: params[:slug])
    @date = Date.parse(params[:date])
    @service_requests = @city.service_requests.where(requested_datetime: @date.all_day)

    respond_to do |format|
      format.xml
    end
  end

  def static
    @links = [
      root_url,
      about_url,
    ] + City.all.map { |city| city_url(city) }

    respond_to do |format|
      format.xml
    end
  end

  private

  def format_lastmod(updated)
    updated.utc.strftime("%Y-%m-%d")
  end
  helper_method :format_lastmod
end
