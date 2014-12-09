module Cities
  class Dc < City
    configure do |c|
      c.name = 'Washington, DC'
      c.endpoint = 'http://app.311.dc.gov/CWI/Open311/v2/'
      c.jurisdiction = 'dc.gov'
    end
  end
end
