# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

# == Schema Information
#
# Table name: statuses
#
#  id            :bigint           not null, primary key
#  duration_ms   :integer
#  error_message :text
#  http_code     :integer
#  request_name  :string
#  created_at    :datetime
#  city_id       :bigint
#
# Indexes
#
#  index_statuses_on_city_id_and_request_name_and_created_at  (city_id,request_name,created_at DESC)
#  index_statuses_on_created_at                               (created_at)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :status do
    city
    request_name { "service_requests" }
    duration_ms { Random.rand(2000) }
    http_code { 200 }

    trait :services do
      request_name { 'service_list' }
    end

    trait :requests do
      request_name { 'service_requests' }
    end
  end
end
