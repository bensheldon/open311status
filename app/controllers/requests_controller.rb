class RequestsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @service_requests = pagy(ServiceRequest.order(requested_datetime: :desc))
  end
end