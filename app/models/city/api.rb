# frozen_string_literal: true

require 'open311'
require 'hashie'

class City
  class Api
    attr_reader :city

    MAX_AGE = 2.days

    def initialize(city)
      @city = city

      api_options = {
        endpoint: city.endpoint,
      }
      api_options[:jurisdiction] = city.jurisdiction if city.jurisdiction
      api_options[:headers] = city.headers if city.headers
      api_options[:format] = city.format if city.format
    end

    def open311
      @_open311 ||= ::Open311.new api_options
    end

    def services_url
      uri = URI.parse "#{city.endpoint}services.xml"
      uri.query = URI.encode_www_form jurisdiction_id: city.jurisdiction if city.jurisdiction.present?
      uri.to_s
    end

    def requests_url
      uri = URI.parse "#{city.endpoint}requests.xml"
      uri.query = URI.encode_www_form jurisdiction_id: city.jurisdiction if city.jurisdiction.present?
      uri.to_s
    end

    def fetch_service_list
      service_list_data = Status::Telemetry.process('service_list', city: city) do
        open311.service_list
      end

      service_list_data = [service_list_data] if service_list_data.is_a?(Hashie::Mash)

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

    def fetch_service_requests(start_param = nil, end_param = nil, collect_telemetry: true)
      start_datetime = start_param.presence || city.service_requests.maximum(:requested_datetime) || MAX_AGE.ago
      end_datetime = end_param.presence

      start_date = start_datetime.utc.xmlschema
      end_date = end_datetime.utc.xmlschema if end_datetime.present?

      if city.requests_omit_timezone
        start_date = start_date.chomp('Z')
        end_date = end_date.chomp('Z') if end_datetime.present?
      end

      requests_data = if collect_telemetry
                        Status::Telemetry.process 'service_requests', city: city do
                          if end_datetime
                            open311.service_requests(start_date: start_date, end_date: end_date)
                          else
                            open311.service_requests(start_date: start_date)
                          end
                        end
                      elsif end_datetime
                        open311.service_requests(start_date: start_date, end_date: end_date)
                      else
                        open311.service_requests(start_date: start_date)
                      end

      requests_data = [requests_data] if requests_data.is_a?(Hashie::Mash)

      Array(requests_data).map do |request_data|
        # Some Service Requests may not have a service_request_id
        next if request_data['service_request_id'].blank?

        city.service_requests.find_or_initialize_by(service_request_id: request_data['service_request_id']).tap do |service_request|
          service_request.raw_data = request_data
          if service_request.changed?
            service_request.save!
          else
            service_request.touch
          end
        end
      end.compact
    end
  end
end
