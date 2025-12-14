# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

# == Schema Information
#
# Table name: service_requests
#
#  id                 :bigint           not null, primary key
#  geometry           :geography        geometry, 4326
#  raw_data           :json
#  requested_datetime :datetime
#  status             :string
#  updated_datetime   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  city_id            :bigint
#  service_request_id :string
#
# Indexes
#
#  index_service_requests_on_city_id                         (city_id)
#  index_service_requests_on_city_id_and_created_at_and_id   (city_id,created_at,id)
#  index_service_requests_on_city_id_and_requested_datetime  (city_id,requested_datetime DESC NULLS LAST)
#  index_service_requests_on_city_id_and_service_request_id  (city_id,service_request_id) UNIQUE
#  index_service_requests_on_created_at                      (created_at)
#  index_service_requests_on_geometry                        (geometry) USING gist
#  index_service_requests_on_requested_datetime              (requested_datetime)
#  index_service_requests_on_status                          (status)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :service_request do
    city

    transient do
      service_request_id { SecureRandom.uuid }
      status { %w[open closed].sample }
      service_name { Faker::Commerce.department(max: 2, fixed_amount: true) }
      description { Faker::Lorem.paragraph(sentence_count: 1, supplemental: false, random_sentences_to_add: 5) }
      requested_datetime { 10.minutes.ago }
      lat { Faker::Address.latitude }
      long { Faker::Address.longitude }
    end

    raw_data do
      {
        'service_request_id' => service_request_id,
        'service_name' => service_name,
        'description' => description,
        'status' => status,
        'requested_datetime' => requested_datetime.iso8601,
        'lat' => lat,
        'long' => long,
      }
    end
  end
end
