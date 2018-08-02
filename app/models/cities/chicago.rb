module Cities
  class Chicago < City
    configure do |c|
      c.name = 'Chicago, IL'
      c.endpoint = 'http://311api.cityofchicago.org/open311/v2/'
    end
  end
end
