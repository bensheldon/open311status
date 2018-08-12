# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :service_request do
    city
    raw_data do
      {
        'service_request_id' => SecureRandom.uuid,
        'service_name' => 'test',
        'description' => 'test',
        'status' => 'open',
        'requested_datetime' => 10.minutes.ago.iso8601,
      }
    end
  end
end
