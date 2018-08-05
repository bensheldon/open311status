module Cities
  class Alexandria < City
    configure do |c|
      c.name = 'Alexandria, VA'
      c.endpoint = 'https://request.alexandriava.gov/GeoReport/Service.ashx/'
    end
  end
end
