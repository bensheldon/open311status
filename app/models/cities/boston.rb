module Cities
  class Boston < City
    configure do |c|
      c.name = 'Boston, MA'
      c.endpoint = 'https://mayors24.cityofboston.gov/open311/v2/'
    end
  end
end
