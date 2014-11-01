# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :service_request do
    city
    service_request_id "MyString"
    status "MyString"
  end
end
