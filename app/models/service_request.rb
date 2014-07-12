class ServiceRequest < ActiveRecord::Base
  belongs_to :city

  def raw_data=(json)
    # denormalize attributes
    self[:service_request_id] = json['service_request_id']
    self[:status] = json['status']
    super
  end
end
