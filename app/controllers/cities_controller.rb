# frozen_string_literal: true

class CitiesController < ApplicationController
  def index
    @cities = City.all
    @service_requests = City.service_requests.first(100)
  end

  def show
    @city = City.find(params.expect(:slug))
    @service_requests = @city.service_requests.first(100)
  end
end
