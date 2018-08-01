module Cities
  class Siegburg < City
    configure do |c|
      c.name = 'Siegburg, Deutschland'
      c.endpoint = 'http://anliegen.siegburg.de/georeport/v2/'
      c.jurisdiction = 'siegburg.de'
    end
  end
end
