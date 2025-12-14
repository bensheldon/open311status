# frozen_string_literal: true

# == Schema Information
#
# Table name: service_definitions
#
#  id           :bigint           not null, primary key
#  raw_data     :json
#  service_code :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  city_id      :bigint
#
# Indexes
#
#  index_service_definitions_on_city_id                   (city_id)
#  index_service_definitions_on_city_id_and_service_code  (city_id,service_code)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id) ON DELETE => cascade
#

class ServiceDefinition < ApplicationRecord
  belongs_to :city, counter_cache: true

  def raw_data=(json)
    self[:service_code] = json['service_code']
    super
  end
end
