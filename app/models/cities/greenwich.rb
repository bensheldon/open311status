module Cities
  class Greenwich < City
    configure do |c|
      c.name = 'Greenwich, Britain'
      c.endpoint = 'https://open311.royalgreenwich.gov.uk/'
    end
  end
end
