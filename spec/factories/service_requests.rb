# == Schema Information
#
# Table name: service_requests
#
#  id                 :integer          not null, primary key
#  service_request_id :string(255)
#  status             :string(255)
#  requested_datetime :datetime
#  updated_datetime   :datetime
#  raw_data           :json
#  created_at         :datetime
#  updated_at         :datetime
#  city_id            :integer
#
# Indexes
#
#  index_service_requests_on_city_id                         (city_id)
#  index_service_requests_on_city_id_and_service_request_id  (city_id,service_request_id) UNIQUE
#  index_service_requests_on_status                          (status)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :service_request do
    city
    service_request_id "MyString"
    status "MyString"
  end
end
