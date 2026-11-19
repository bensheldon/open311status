# frozen_string_literal: true

module Cities
  class RequestsController < ApplicationController
    def show
      @service_request = City.find(params.expect(:city_slug)).find_service_request(params.expect(:service_request_id))
    end
  end
end
