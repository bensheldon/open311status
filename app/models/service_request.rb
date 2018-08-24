# == Schema Information
#
# Table name: service_requests
#
#  id                 :bigint(8)        not null, primary key
#  geometry           :geography({:srid geometry, 4326
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
#  index_service_requests_on_geometry                        (geometry) USING gist
#  index_service_requests_on_status                          (status)
#

class ServiceRequest < ApplicationRecord
  SLUG_SIZE = 100

  belongs_to :city
  has_one :global_index, as: :searchable, inverse_of: :service_request


  def parameterize
    { city_slug: city.slug, service_request_id: service_request_id, slug: slug }
  end

  def raw_data=(json)
    super.tap do
      self[:service_request_id] = json['service_request_id']
      self[:status] = json['status']
      self[:requested_datetime] = DateTime.iso8601(json['requested_datetime']) if json['requested_datetime'].present?
      self[:updated_datetime] = DateTime.iso8601(json['updated_datetime']) if json['updated_datetime'].present?
      self[:geometry] = "POINT(#{json['long']} #{json['lat']})" if json['lat'].present?
    end
  rescue => e
    Raven.capture_exception e,
      extra: {
        data: json,
      }
  end

  def slug
    description = raw_data['description'].presence || ''
    slug = description.gsub(/(-|_)/, ' ').squish.encode.to_slug.normalize.to_s.downcase
    slug = slug[0, SLUG_SIZE].gsub(/-$/, '') if slug.size > SLUG_SIZE
    slug
  end
end
