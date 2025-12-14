# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

# == Schema Information
#
# Table name: service_definitions
#
#  id           :bigint           not null, primary key
#  raw_data     :json
#  service_code :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  city_id      :bigint
#
# Indexes
#
#  index_service_definitions_on_city_id                   (city_id)
#  index_service_definitions_on_city_id_and_service_code  (city_id,service_code)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :service_definition do
    city
    service_code { "MyString" }
  end
end
