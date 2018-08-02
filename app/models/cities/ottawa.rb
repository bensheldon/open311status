module Cities
  class Ottawa < City
    configure do |c|
      c.name = 'Ottowa, ON'
      c.endpoint = 'https://city-of-ottawa-prod.apigee.net/open311/v2/'
    end
  end
end
