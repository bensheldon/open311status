module Cities
  class GrandRapids < City
    configure do |c|
      c.name = 'Grand Rapids, MI'
      c.endpoint = 'http://grcity.spotreporters.com/open311/v2/'
      c.jurisdiction = 'grcity.us'
    end
  end
end
