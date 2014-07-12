# Read about factories at https://github.com/thoughtbot/factory_girl

module Cities
  class Test < City
  end
end

FactoryGirl.define do
  factory :city do
    factory :test_city, class: 'Cities::Test' do
      slug 'test'
    end
  end
end
