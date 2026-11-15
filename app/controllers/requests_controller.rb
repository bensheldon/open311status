# frozen_string_literal: true

class RequestsController < ApplicationController
  PER_PAGE = 50

  def index
    all = City.service_requests
    @page = params.fetch(:page, 1).to_i
    @total_pages = [(all.size.to_f / PER_PAGE).ceil, 1].max
    raise ActionController::RoutingError, 'Page not found' unless @page.between?(1, @total_pages)

    @service_requests = all.slice((@page - 1) * PER_PAGE, PER_PAGE) || []
  end
end
