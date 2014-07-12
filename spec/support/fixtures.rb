module FixtureMacros
  def service_requests_json
    File.read Pathname('spec/fixtures/service_requests.json')
  end
end
