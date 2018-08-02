module Cities
  class Bruhl < City
    configure do |c|
      c.name = 'Brühl, Deutschland'
      c.endpoint = 'https://www.achtet-auf-bruehl.de/georeport/v2/'
      c.jurisdiction = 'bruehl.de'
    end
  end
end
