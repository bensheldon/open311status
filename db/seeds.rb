City.load!

City.all.each do |city|
  FactoryBot.create_list :service_request, 3,
                         city: city,
                         requested_datetime: Random.rand(10_000).minutes.ago
end

GlobalIndex.refresh
