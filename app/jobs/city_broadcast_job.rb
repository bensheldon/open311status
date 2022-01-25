# frozen_string_literal: true

class CityBroadcastJob < ApplicationJob
  def perform(city)
    @city = city
    ActionCable.server.broadcast "cities",
                                 city_id: @city.id,
                                 city_html: render_city
  end

  private

  def render_city
    ApplicationController.renderer.render(partial: 'cities/city_row_content', locals: { city: CityDecorator.decorate(@city) })
  end
end
