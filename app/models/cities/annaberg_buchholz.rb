module Cities
  class AnnabergBuchholz < City
    configure do |c|
      c.name = 'Annaberg-Buchholz, Deutschland'
      c.endpoint = 'http://anliegen.annaberg-buchholz.de/georeport/v2/'
      c.jurisdiction = 'annberg-buchholz.de'
    end
  end
end
