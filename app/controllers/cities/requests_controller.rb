# frozen_string_literal: true

module Cities
  class RequestsController < ApplicationController
    def show
      @service_request = City.find_by!(slug: params[:city_slug]).service_requests.find_by(service_request_id: params[:service_request_id])
      return redirect_to polymorphic_path(@service_request), status: 301 if @service_request.slug.present? && params[:slug] != @service_request.slug
    end
  end
end
