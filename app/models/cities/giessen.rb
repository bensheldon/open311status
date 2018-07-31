module Cities
  class Giessen < City
    configure do |c|
      c.name = 'Gießen, Deutschland'
      c.endpoint = 'https://maengelmelder.giessen.de/georeport/v2/'
    end
  end
end
