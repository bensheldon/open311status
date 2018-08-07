class CitiesController < ApplicationController
  def index
    @cities = City.includes(:service_list_status, :service_requests_status).all.order(slug: :asc)
  end

  def show
    @city = City.find_by!(slug: params[:slug])
  end
end
