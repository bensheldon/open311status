module Cities
  class Columbus < City
    configure do |c|
      c.name = 'Columbus, IN'
      c.endpoint = 'http://csr.columbus.in.gov/csr/open311/v2/'
      c.jurisdiction = 'columbus.in.gov'
    end
  end
end
