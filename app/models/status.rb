# == Schema Information
#
# Table name: statuses
#
#  id            :bigint(8)        not null, primary key
#  city_id       :integer
#  request_name  :string
#  duration_ms   :integer
#  http_code     :integer
#  created_at    :datetime
#  error_message :text
#
# Indexes
#
#  index_statuses_on_city_id                   (city_id)
#  index_statuses_on_city_id_and_request_name  (city_id,request_name)
#

class Status < ApplicationRecord
  belongs_to :city

  scope :latest, ->(count = 1) {
    rankings = <<~SQL
      SELECT id, RANK() OVER(PARTITION BY city_id, request_name ORDER BY created_at DESC) rank
      FROM statuses
    SQL

    joins("INNER JOIN (#{rankings}) rankings ON rankings.id = statuses.id")
        .where("rankings.rank <= :count", count: count)
  }
  scope :service_list, -> { where(request_name: 'service_list') }
  scope :service_requests, -> { where(request_name: 'service_requests') }
  scope :errored, -> { where('http_code >= ?', 400) }
  scope :time_periods, -> { select("*", "date_trunc('hour', created_at) + INTERVAL '10 min' * FLOOR(date_part('minute', created_at) / 10.0) AS time_period") }

  validates :request_name, inclusion: { in: %w[service_list service_requests] }
end
