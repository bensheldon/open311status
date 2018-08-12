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

class City < ActiveRecord::Base
  delegate *Configuration::ATTRIBUTES, to: :configuration, allow_nil: true

  has_many :service_requests
  has_many :service_definitions
  has_many :statuses

  has_one :service_list_status, -> { service_list.latest(1) }, class_name: 'Status'
  has_one :service_requests_status, -> { service_requests.latest(1) }, class_name: 'Status'
  has_many :service_list_statuses, -> { service_list }, class_name: 'Status'
  has_many :service_requests_statuses, -> { service_requests }, class_name: 'Status'

  validates :slug, uniqueness: true

  class << self
    def instance(slug)
      self.where(slug: slug).first_or_create
    end

    # Loads city configuration data into database
    def load!
      configs = Rails.configuration.cities
      configs.each do |slug, city_config|
        instance(slug)
      end
    end
  end

  def to_param
    slug
  end

  def api
    @api ||= City::Api.new(self)
  end

  def configuration
    @configuration ||= City::Configuration.new(Rails.configuration.cities[slug])
  end

  def uptime_percent(status_type, start: 2.days.ago)
    start_floor = start.change(min: 10 * (Time.now().min.to_f / 10).floor)

    query = if status_type == 'service_list'
              service_list_statuses
            else
              service_requests_statuses
            end

    statuses = query.time_periods
                    .errored
                    .where('created_at >= ?', start_floor)
                    .order("time_period ASC")

    downtime_periods = statuses.group_by { |status| status.time_period }.keys.size

    100 - (downtime_periods.to_f / ((Time.current - start_floor) / 10.minutes)) * 100
  end
end
