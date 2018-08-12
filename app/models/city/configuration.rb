class City
  class Configuration
    include ActiveModel::Model

    ATTRIBUTES = [
        :name,
        :endpoint,
        :jurisdiction,
        :format,
        :headers,
    ]

    attr_accessor *ATTRIBUTES

    def format
      (@format || :xml).to_sym
    end

    def headers
      (@headers || {}).symbolize_keys
    end
  end
end
