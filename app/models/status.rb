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

  scope :latest_by_city, lambda { |request_name, count: 1|
    # This scope is complex. The table_reference (which is `cities`) is aliased to be
    # the model's table (`statuses`) so that when this scope is used as in an association
    # the eagerloaded foreign key query (`WHERE statuses.city_id` IN ...) will work properly.
    #
    # SELECT <columns>
    # FROM <table reference>
    #      JOIN LATERAL <subquery>
    #      ON TRUE;
    #
    query = select('subquery.*').from('(SELECT *, id AS city_id FROM cities) AS statuses')

    join_sql = <<~SQL.squish
      JOIN LATERAL (
        SELECT * FROM statuses AS sub_statuses
        WHERE sub_statuses.city_id = statuses.city_id
          AND sub_statuses.request_name = :request_name
        ORDER BY created_at DESC LIMIT :count
      ) AS subquery ON TRUE
    SQL

    query.joins(sanitize_sql_array([join_sql, { request_name:, count: }]))
  }
  scope :service_list, -> { where(request_name: 'service_list') }
  scope :service_requests, -> { where(request_name: 'service_requests') }
  scope :errored, -> { where(http_code: 400..) }
  scope :time_periods, -> { select("*", "date_trunc('hour', created_at) + INTERVAL '10 min' * FLOOR(date_part('minute', created_at) / 10.0) AS time_period") }

  validates :request_name, inclusion: { in: %w[service_list service_requests] }
end
