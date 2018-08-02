module Cities
  class Rostok < City
    configure do |c|
      c.name = 'Rostock, Deutschland'
      c.endpoint = 'https://geo.sv.rostock.de/citysdk/'
      c.jurisdiction = 'rostock.de'
    end
  end
end
