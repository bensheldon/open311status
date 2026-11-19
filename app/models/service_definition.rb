# frozen_string_literal: true

class ServiceDefinition
  attr_reader :raw_data

  def initialize(raw_data)
    @raw_data = raw_data.to_h
  end

  def service_code
    raw_data['service_code']
  end
end
