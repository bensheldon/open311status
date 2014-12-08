class ServiceDefinition < ActiveRecord::Base
  belongs_to :city

  def raw_data=(json)
    self[:service_code] = json['service_code']
    super
  end
end
