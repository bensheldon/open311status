module Cities
  class Koln < City
    configure do |c|
      c.name = 'Köln / Cologne, Deutschland'
      c.endpoint = 'https://sags-uns.stadt-koeln.de/georeport/v2/'
      c.jurisdiction = 'stadt-koeln.de'
    end
  end
end
