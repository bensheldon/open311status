# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :status do
    city
    request_name "service_requests"
    duration_ms { Random.rand(2000) }
    http_code 200

    trait :services do
      request_name 'service_list'
    end

    trait :requests do
      request_name 'service_requests'
    end
  end
end
