module Cities
  class Helsinki < City
    configure do |c|
      c.name = 'Helsinki, Suomi'
      c.endpoint = 'https://asiointi.hel.fi/palautews/rest/v1/'
    end
  end
end
