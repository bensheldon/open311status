# Read about factories at https://github.com/thoughtbot/factory_girl

unless defined? Cities::TestCity
  module Cities
    class TestCity < City
    end
  end
end

FactoryGirl.define do
  factory :city do
    factory :test_city, class: 'Cities::TestCity' do
      slug 'test'
    end
  end
end
