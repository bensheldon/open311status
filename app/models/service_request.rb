# frozen_string_literal: true

# == Schema Information
#
# Table name: service_requests
#
#  id                 :bigint           not null, primary key
#  geometry           :geography        geometry, 4326
#  raw_data           :json
#  requested_datetime :datetime
#  status             :string
#  updated_datetime   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  city_id            :bigint
#  service_request_id :string
#
# Indexes
#
#  index_service_requests_on_city_id                         (city_id)
#  index_service_requests_on_city_id_and_created_at_and_id   (city_id,created_at,id)
#  index_service_requests_on_city_id_and_requested_datetime  (city_id,requested_datetime DESC NULLS LAST)
#  index_service_requests_on_city_id_and_service_request_id  (city_id,service_request_id) UNIQUE
#  index_service_requests_on_created_at                      (created_at)
#  index_service_requests_on_geometry                        (geometry) USING gist
#  index_service_requests_on_requested_datetime              (requested_datetime)
#  index_service_requests_on_status                          (status)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id) ON DELETE => cascade
#

class ServiceRequest < ApplicationRecord
  include OrderQuery

  SLUG_SIZE = 100

  belongs_to :city
  has_one :global_index, as: :searchable, inverse_of: :service_request

  order_query :order_requested, [:requested_datetime, :desc, { unique: false, nulls: :last }]
  scope :by_requested_datetime, -> { order("requested_datetime DESC NULLS LAST") }

  def parameterize
    { city_slug: city.slug, service_request_id:, slug: }
  end

  def raw_data=(json)
    super.tap do
      self[:service_request_id] = json['service_request_id']
      self[:status] = json['status']
      self[:requested_datetime] = DateTime.iso8601(json['requested_datetime']) if json['requested_datetime'].present?
      self[:updated_datetime] = DateTime.iso8601(json['updated_datetime']) if json['updated_datetime'].present?
      self[:geometry] = "POINT(#{json['long']} #{json['lat']})" if json['lat'].present?
    end
  rescue StandardError => e
    Raven.capture_exception e,
                            extra: {
                              data: json,
                            }
  end

  def raw_data
    super || {}
  end

  def slug
    description = raw_data['description'].presence || ''
    slug = description.gsub(/(-|_)/, ' ').squish.encode.to_slug.normalize.to_s.downcase
    slug = slug[0, SLUG_SIZE].gsub(/-$/, '') if slug.size > SLUG_SIZE
    slug
  end
end
