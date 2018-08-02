module Cities
  class Brookline < City
    configure do |c|
      c.name = 'Brookline, MA'
      c.endpoint = 'http://spot.brooklinema.gov/open311/v2/'
      c.jurisdiction = 'brooklinema.gov'
    end
  end
end
