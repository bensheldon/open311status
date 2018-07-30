module Cities
  class Bonn < City
    configure do |c|
      c.name = 'Bonn, Deutschland'
      c.endpoint = 'http://anliegen.bonn.de/georeport/v2/'
      c.jurisdiction = 'ville.quebec.qc.ca'
    end
  end
end
