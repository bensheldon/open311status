# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :city, class: 'Cities::Chicago' do
    slug 'chicago'
  end
end
