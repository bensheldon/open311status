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

    def services_url
      uri = URI.parse "#{city.endpoint}services.xml"
      if city.jurisdiction.present?
        uri.query = URI.encode_www_form jurisdiction_id: city.jurisdiction
      end
      uri.to_s
    end

    def requests_url
      uri = URI.parse "#{city.endpoint}requests.xml"
      if city.jurisdiction.present?
        uri.query = URI.encode_www_form jurisdiction_id: city.jurisdiction
      end
      uri.to_s
    end

    def fetch_service_list
      service_list_data = Status::Telemetry.process('service_list', city: city) do
        open311.service_list
      end

      if service_list_data.is_a?(Hashie::Mash)
        service_list_data = [service_list_data]
      end

      Array(service_list_data).map do |request_data|
        city.service_definitions.find_or_initialize_by(service_code: request_data['service_code']).tap do |service_definition|
          service_definition.raw_data = request_data
          if service_definition.changed?
            service_definition.save!
          else
            service_definition.touch
          end
        end
      end
    end

    def fetch_service_requests(start = nil)
      if start
        start_datetime = start
      else
        start_datetime = city.service_requests.maximum(:requested_datetime) || MAX_AGE.ago
      end

      requests_data = Status::Telemetry.process 'service_requests', city: city do
        open311.service_requests(start_date: start_datetime.xmlschema)
      end

      # TODO: Page over the results in case we don't get all of the service requests newer than
      # the date above
      if requests_data.is_a?(Hashie::Mash)
        requests_data = [requests_data]
      end

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
