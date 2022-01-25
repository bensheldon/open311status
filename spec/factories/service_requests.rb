# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_girl

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
