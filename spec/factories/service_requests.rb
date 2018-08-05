# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :service_request do
    city
    service_request_id { SecureRandom.uuid }
    status "MyString"
  end
end
