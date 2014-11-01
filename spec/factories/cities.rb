# Read about factories at https://github.com/thoughtbot/factory_girl

Cities.send(:remove_const, :TestCity) if defined? Cities::TestCity

unless defined? Cities::TestCity
  module Cities
    class TestCity < City
      configure do |c|
        c.name = 'Test'
        c.state = 'TS'
        c.endpoint = 'http://test.org/open311'
        c.jurisdiction = 'test.org'
      end
    end
  end
end

FactoryGirl.define do
  factory :city, class: 'Cities::TestCity' do
    slug 'test'
  end
end
