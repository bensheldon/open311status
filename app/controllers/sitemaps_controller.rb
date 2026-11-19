# frozen_string_literal: true

class SitemapsController < ApplicationController
  def index
    @cities = City.all
  end

  def city
    @city = City.find(params.expect(:slug))
  end

  def static
    @links = [root_url, about_url, requests_url] + City.all.map { |city| city_url(city) }
  end
end
