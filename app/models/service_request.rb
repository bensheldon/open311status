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
