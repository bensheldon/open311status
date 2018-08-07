# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :status do
    city
    request_name "service_requests"
    duration_ms 15
    http_code 200
  end
end
