class City < ActiveRecord::Base
  class_attribute :configuration

  self.inheritance_column = :slug
  has_many :service_requests

  validates :slug, uniqueness: true

  def open311
    config = { endpoint: endpoint }
    config[:jurisdiction] = jurisdiction if jurisdiction

    @open311 ||= Open311.new config
  end

  def method_missing(meth, *args, &block)
    return configuration.send(meth) if configuration.respond_to? meth
    super
  end

  class << self
    def instance
      self.where(slug: sti_name).first_or_create
    end

    def configure(&block)
      self.configuration = Struct.new(
        :name, :state, :endpoint, :jurisdiction
      ).new.tap { |config| block.call config }
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
