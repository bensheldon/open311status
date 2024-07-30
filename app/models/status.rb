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
#  city_id       :bigint(8)
#
# Indexes
#
#  index_statuses_on_city_id_and_request_name_and_created_at  (city_id,request_name,created_at DESC)
#  index_statuses_on_created_at                               (created_at)
#
# Foreign Keys
#
#  fk_rails_...  (city_id => cities.id) ON DELETE => cascade
#

class Status < ApplicationRecord
  belongs_to :city

  scope :service_list, -> { where(request_name: 'service_list') }
  scope :service_requests, -> { where(request_name: 'service_requests') }
  scope :errored, -> { where(http_code: 400..) }
  scope :time_periods, -> { select("*", "date_trunc('hour', created_at) + INTERVAL '10 min' * FLOOR(date_part('minute', created_at) / 10.0) AS time_period") }

  validates :request_name, inclusion: { in: %w[service_list service_requests] }
end
