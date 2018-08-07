# == Schema Information
#
# Table name: cities
#
#  id         :bigint(8)        not null, primary key
#  slug       :string
#  created_at :datetime
#  updated_at :datetime
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
  has_one :service_list_status,
    -> { where(request_name: 'service_list').order("created_at DESC") },
    class_name: 'Status'
  has_one :service_requests_status,
    -> { where(request_name: 'service_requests').order("created_at DESC") },
    class_name: 'Status'

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
end
