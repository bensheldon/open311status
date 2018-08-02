module Cities
  class Bloomington < City
    configure do |c|
      c.name = 'Bloomington, IN'
      c.endpoint = 'https://bloomington.in.gov/crm/open311/v2/'
      c.jurisdiction = 'bloomington.in.gov'
    end
  end
end
