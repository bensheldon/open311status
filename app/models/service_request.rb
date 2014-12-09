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

class ServiceRequest < ActiveRecord::Base
  belongs_to :city

  def raw_data=(json)
    self[:service_request_id] = json['service_request_id']
    self[:status] = json['status']
    self[:requested_datetime] = DateTime.iso8601 json['requested_datetime']
    self[:updated_datetime] = DateTime.iso8601 json['updated_datetime']
    super
  end
end
