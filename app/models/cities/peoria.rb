module Cities
  class Peoria < City
    configure do |c|
      c.name = 'Peoria, IL'
      c.endpoint = 'https://ureport.peoriagov.org/crm/open311/v2/'
      c.jurisdiction = 'peoriagov.org'
    end
  end
end
