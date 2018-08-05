class CitiesController < ApplicationController
  def index
    @cities = City.all.order(slug: :asc)
  end

  def show
    @city = City.find_by!(slug: params[:slug])
  end
end
