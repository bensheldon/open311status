# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :service_definition do
    city
    service_code { "MyString" }
  end
end
