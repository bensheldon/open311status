class City
  class Configuration
    include ActiveModel::Model

    ATTRIBUTES = [
        :name,
        :endpoint,
        :jurisdiction,
        :format,
        :headers,
        :notes,
        :requests_limit,
        :requests_omit_timezone,
    ]

    attr_accessor *ATTRIBUTES

    def format
      (@format || :json).to_sym
    end

    def headers
      (@headers || {}).symbolize_keys
    end
  end
end
