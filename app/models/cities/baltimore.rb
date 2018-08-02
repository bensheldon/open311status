module Cities
  class Baltimore < City
    configure do |c|
      c.name = 'Baltimore, MD'
      c.endpoint = 'http://311.baltimorecity.gov/open311/v2/'
      c.jurisdiction = 'baltimorecity.gov'
    end
  end
end
