module Cities
  class Surrey < City
    configure do |c|
      c.name = 'Surrey, BC'
      c.endpoint = 'http://cosmos.surrey.ca/api/open311/'
      c.jurisdiction = 'surrey.ca'
    end
  end
end
