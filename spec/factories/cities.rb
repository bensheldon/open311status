# Read about factories at https://github.com/thoughtbot/factory_girl

Cities.send(:remove_const, :Test) if defined? Cities::Test

unless defined? Cities::Test
  module Cities
    class Test < City
      configure do |c|
        c.name = 'Test City'
        c.endpoint = 'http://test.org/open311'
        c.jurisdiction = 'test.org'
      end
    end
  end
end

FactoryGirl.define do
  factory :city, class: 'Cities::Test' do
    slug 'test'
  end
end
