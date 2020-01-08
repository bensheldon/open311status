# frozen_string_literal: true

# == Schema Information
#
# Table name: statuses
#
#  id            :bigint(8)        not null, primary key
#  duration_ms   :integer
#  error_message :text
#  http_code     :integer
#  request_name  :string
#  created_at    :datetime
#  city_id       :integer
#
# Indexes
#
#  index_statuses_on_city_id_and_request_name_and_created_at  (city_id,request_name,created_at DESC)
#

class Status < ApplicationRecord
  belongs_to :city

  scope :latest_by_city, lambda { |count = 1|
    where(arel_table[:id].in(Arel.sql(
                               <<~SQL
                                 SELECT latest_statuses.id
                                 FROM cities
                                 LEFT JOIN LATERAL (
                                   SELECT id
                                   FROM statuses
                                   WHERE statuses.city_id = cities.id
                                   ORDER BY created_at DESC
                                   LIMIT #{sanitize_sql_array(['?', count])}
                                 ) latest_statuses ON true
                               SQL
                             )))
  }
  scope :service_list, -> { where(request_name: 'service_list') }
  scope :service_requests, -> { where(request_name: 'service_requests') }
  scope :errored, -> { where('http_code >= ?', 400) }
  scope :time_periods, -> { select("*", "date_trunc('hour', created_at) + INTERVAL '10 min' * FLOOR(date_part('minute', created_at) / 10.0) AS time_period") }

  validates :request_name, inclusion: { in: %w[service_list service_requests] }
end
