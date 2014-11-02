require 'open311'

class City
  class Api
    attr_reader :city, :open311

    MAX_AGE = 2.days

    def initialize(city)
      @city = city

      api_options = {
        endpoint: city.endpoint
      }
      api_options[:jurisdiction] if city.jurisdiction
      @open311 = ::Open311.new api_options
    end

    def fetch_service_list
      response = connection.get 'services.json'
    end

    def fetch_service_requests
      start_datetime = city.service_requests.maximum(:requested_datetime) || MAX_AGE.ago

      requests_data = open311.service_requests(start_date: start_datetime)

      Array(requests_data).map do |request_data|
        city.service_requests.find_or_initialize_by(service_request_id: request_data['service_request_id']).tap do |service_request|
          service_request.raw_data = request_data
          service_request.save!
        end
      end
    end
  end
end
