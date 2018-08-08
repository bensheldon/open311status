module Cities
  class Alexandria < City
    configure do |c|
      c.name = 'Alexandria, VA'
      c.endpoint = 'https://request.alexandriava.gov/GeoReport/Service.ashx/'

      # Zlib::DataError: incorrect header check when using
      # default headers that include `deflate`
      c.headers = { accept_encoding: '' }
    end
  end
end
