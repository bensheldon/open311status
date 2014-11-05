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
      api_options[:jurisdiction] = city.jurisdiction if city.jurisdiction
      @open311 = ::Open311.new api_options
    end

    def fetch_service_list
      response = connection.get 'services.json'
    end

    def fetch_service_requests(start = nil)
      if start
        start_datetime = start
      else
        start_datetime = city.service_requests.maximum(:requested_datetime) || MAX_AGE.ago
      end

      requests_data = open311.service_requests(start_date: start_datetime.xmlschema)

      Array(requests_data).map do |request_data|
        # Some Service Requests may not have a service_request_id
        return nil unless request_data['service_request_id']

        city.service_requests.find_or_initialize_by(service_request_id: request_data['service_request_id']).tap do |service_request|
          service_request.raw_data = request_data
          if service_request.changed?
            service_request.save!
          else
            service_request.touch
          end
        end
      end
    end
  end
end
