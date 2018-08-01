module Cities
  class Lamia < City
    configure do |c|
      c.name = 'Lamía, Elláda'
      c.endpoint = 'https://participation.citysdk.lamia-city.gr/rest/open311/v1/'
    end
  end
end
