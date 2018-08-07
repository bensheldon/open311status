# == Schema Information
#
# Table name: service_requests
#
#  id                 :bigint(8)        not null, primary key
#  raw_data           :json
#  requested_datetime :datetime
#  status             :string
#  updated_datetime   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  city_id            :integer
#  service_request_id :string
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
    super.tap do
      self[:service_request_id] = json['service_request_id']
      self[:status] = json['status']
      self[:requested_datetime] = DateTime.iso8601(json['requested_datetime']) if json['requested_datetime'].present?
      self[:updated_datetime] = DateTime.iso8601(json['updated_datetime']) if json['updated_datetime'].present?
    end
  rescue => e
    Raven.capture_exception e,
      extra: {
        data: json,
      }
  end
end
