# == Schema Information
#
# Table name: service_definitions
#
#  id           :bigint(8)        not null, primary key
#  raw_data     :json
#  service_code :string
#  created_at   :datetime
#  updated_at   :datetime
#  city_id      :integer
#
# Indexes
#
#  index_service_definitions_on_city_id                   (city_id)
#  index_service_definitions_on_city_id_and_service_code  (city_id,service_code)
#

class ServiceDefinition < ActiveRecord::Base
  belongs_to :city

  def raw_data=(json)
    self[:service_code] = json['service_code']
    super
  end
end
