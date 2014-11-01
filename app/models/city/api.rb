require 'faraday'
require 'json'

class City
  class Api
    attr_reader :city, :connection

    MAX_AGE = 24.hours

    def initialize(city)
      @city = city
      @connection = Faraday.new url: city.endpoint
    end

    def fetch_service_list
      response = connection.get 'services.json'
    end

    def fetch_service_requests
      start_datetime = city.service_requests.maximum(:requested_datetime) || MAX_AGE.ago

      response = connection.get 'requests.json' do |req|
        req.params['start_date'] = start_datetime.iso8601
      end

      requests_data = JSON.parse response.body

      requests_data.map do |request_data|
        city.service_requests.find_or_initialize_by(service_request_id: request_data['service_request_id']).tap do |service_request|
          service_request.raw_data = request_data
          service_request.save!
        end
      end
    end
  end
end
