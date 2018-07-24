module Cities
  class SanFrancisco < City
    configure do |c|
      c.name = 'San Francisco, CA'
      c.endpoint = 'http://mobile311.sfgov.org/open311/v2/'
      c.jurisdiction = 'sfgov.org'
    end
  end
end
