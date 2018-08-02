# == Schema Information
#
# Table name: service_definitions
#
#  id           :integer          not null, primary key
#  city_id      :integer
#  service_code :string(255)
#  raw_data     :json
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_service_definitions_on_city_id                   (city_id)
#  index_service_definitions_on_city_id_and_service_code  (city_id,service_code)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :service_definition do
    city nil
    service_code "MyString"
  end
end
