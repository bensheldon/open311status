module Cities
  class Rostok < City
    configure do |c|
      c.name = 'Turku, Suomi'
      c.endpoint = 'https://api.turku.fi/feedback/v1/'
    end
  end
end
