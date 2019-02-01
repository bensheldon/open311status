# frozen_string_literal: true

module FixtureMacros
  def service_requests_json
    File.read Pathname('spec/fixtures/service_requests.json')
  end

  def service_list_json
    File.read Pathname('spec/fixtures/service_list.json')
  end
end

RSpec.configure do |config|
  config.include(FixtureMacros)
end
