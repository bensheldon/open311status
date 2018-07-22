# == Schema Information
#
# Table name: statuses
#
#  id           :integer          not null, primary key
#  city_id      :integer
#  request_name :string(255)
#  duration_ms  :integer
#  http_code    :integer
#  created_at   :datetime
#
# Indexes
#
#  index_statuses_on_city_id                   (city_id)
#  index_statuses_on_city_id_and_request_name  (city_id,request_name)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :status do
    city nil
    type ""
    duration_ms 1
    status 1
  end
end
