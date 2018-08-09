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
  class_attribute :configuration

  self.inheritance_column = :slug

  has_many :service_requests
  has_many :service_definitions
  has_many :statuses

  has_one :service_list_status, -> { service_list.latest(1) }, class_name: 'Status'
  has_one :service_requests_status, -> { service_requests.latest(1) }, class_name: 'Status'
  has_many :service_list_statuses, -> { service_list }, class_name: 'Status'
  has_many :service_requests_statuses, -> { service_requests }, class_name: 'Status'

  validates :slug, uniqueness: true

  class << self
    def instance
      self.where(slug: sti_name).first_or_create
    end

    def configure
      self.configuration ||= City::Configuration.new
      yield(configuration) if block_given?
      configuration
    end

    alias_method :config, :configure

    # Loads city configuration data into database
    def load!
      Dir[Rails.root.join('app', 'models', 'cities', '*.rb')].each { |f| require_dependency(f) }
      Cities.constants(false).map { |klass| Cities.const_get(klass).instance }
    end

    def find_sti_class(slug)
      "Cities::#{ slug.camelize }".constantize
    end

    def sti_name
      self.name.demodulize.underscore
    end
  end

  def to_param
    slug
  end

  def method_missing(meth, *args, &block)
    return configuration.send(meth) if configuration.respond_to? meth
    super
  end

  def respond_to?(method_sym, include_private = false)
    return true if configuration.respond_to?(method_sym)
    super
  end

  def api
    @api ||= City::Api.new(self)
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
