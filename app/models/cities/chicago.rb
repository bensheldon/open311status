module Cities
  class Chicago < City
    configure :chicago,
      endpoint: 'http://311api.cityofchicago.org/open311/v2/'

  end
end
