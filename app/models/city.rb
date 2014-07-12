class City < ActiveRecord::Base
  class_attribute :properties

  self.inheritance_column = :slug
  has_many :service_requests

  validates :slug, uniqueness: true

  class << self
    def instance
      self.where(slug: sti_name).first_or_create
    end

    def configure(slug, properties)
      self.properties = properties
    end

    def load
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
end
