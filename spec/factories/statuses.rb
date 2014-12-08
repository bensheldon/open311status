# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :status do
    city nil
    type ""
    duration_ms 1
    status 1
  end
end
