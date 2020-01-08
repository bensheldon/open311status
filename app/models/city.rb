# frozen_string_literal: true

# == Schema Information
#
# Table name: cities
#
#  id                        :bigint(8)        not null, primary key
#  service_definitions_count :integer          default(0), not null
#  slug                      :string
#  created_at                :datetime
#  updated_at                :datetime
#
# Indexes
#
#  index_cities_on_slug  (slug) UNIQUE
#

class City < ApplicationRecord
  delegate(*Configuration::ATTRIBUTES, to: :configuration, allow_nil: true)

  has_many :service_requests, dependent: :destroy
  has_many :service_definitions, dependent: :destroy
  has_many :statuses, dependent: :destroy

  has_one :service_list_status, -> { latest_by_city(1).where(request_name: :service_list).order(created_at: :desc) }, class_name: 'Status', inverse_of: :city
  has_one :service_requests_status, -> { latest_by_city(1).where(request_name: :service_requests).order(created_at: :desc) }, class_name: 'Status', inverse_of: :city
  has_many :service_list_statuses, -> { service_list }, class_name: 'Status', inverse_of: :city
  has_many :service_requests_statuses, -> { service_requests }, class_name: 'Status', inverse_of: :city
  has_many :service_list_status_errors, lambda {
    start_floor = 2.days.ago.change(min: 10 * (Time.now.min.to_f / 10).floor)
    service_list.time_periods.errored.where('created_at >= ?', start_floor).order("time_period ASC")
  }, class_name: 'Status', inverse_of: :city
  has_many :service_request_status_errors, lambda {
    start_floor = 2.days.ago.change(min: 10 * (Time.now.min.to_f / 10).floor)
    service_requests.time_periods.errored.where('created_at >= ?', start_floor).order("time_period ASC")
  }, class_name: 'Status', inverse_of: :city

  validates :slug, uniqueness: true

  class << self
    def instance(slug)
      where(slug: slug).first_or_create
    end

    # Loads city configuration data into database
    def load!
      configs = Rails.configuration.cities
      configs.each do |slug, _city_config|
        instance(slug)
      end
    end
  end

  def to_param
    slug
  end

  def api
    @_api ||= City::Api.new(self)
  end

  def configuration
    @_configuration ||= City::Configuration.new(Rails.configuration.cities[slug])
  end

  def uptime_percent(status_type, start: 2.days.ago)
    start_floor = start.change(min: 10 * (Time.now.min.to_f / 10).floor)

    statuses = if status_type == 'service_list'
                 service_list_status_errors
               else
                 service_request_status_errors
               end

    downtime_periods = statuses.group_by(&:time_period).keys.size

    100 - (downtime_periods.to_f / ((Time.current - start_floor) / 10.minutes)) * 100
  end
end
