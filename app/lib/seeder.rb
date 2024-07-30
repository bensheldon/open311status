# frozen_string_literal: true

class Seeder
  def call
    City.load!

    City.find_each do |city|
      ActiveRecord::Base.transaction(requires_new: true) do
        3.times do
          FactoryBot.create :service_request,
                            city:,
                            requested_datetime: Random.rand(10_000).minutes.ago

          FactoryBot.create :status, :services, city:, created_at: Random.rand(10_000).minutes.ago
          FactoryBot.create :status, :requests, city:, created_at: Random.rand(10_000).minutes.ago
        end
      end
    end

    city = City.instance('san_francisco')
    ActiveRecord::Base.transaction(requires_new: true) do
      50.times do
        FactoryBot.create :service_request,
                          city:,
                          requested_datetime: Random.rand(10_000).minutes.ago
      end
    end

    GlobalIndex.refresh
  end
end
