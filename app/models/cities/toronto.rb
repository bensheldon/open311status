module Cities
  class Toronto < City
    configure do |c|
      c.name = 'Toronto, ON'
      c.endpoint = 'https://secure.toronto.ca/webwizard/ws/'
      c.jurisdiction = 'toronto.ca'
    end
  end
end
