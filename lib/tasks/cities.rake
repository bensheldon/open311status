namespace :cities do
  desc 'Load all cities into the database'
  task :load => :environment do |t, args|
    Rails.logger = Logger.new(STDOUT)
    Rails.logger.info "Populating database with cities"
    City.load!
  end

  desc 'Fetch service requests for all cities, or list of individual cities'
  task :service_requests, [:override] => :environment do |task, args|
    Rails.logger = Logger.new(STDOUT)
    overrides = Array(args[:override]) + Array(args.extras)

    if overrides.size > 0
      cities = overrides.map { |slug| City.find_by! slug: slug }
    else
      cities = City.all
    end

    cities.each do |city|
      FetchServiceRequestsJob.perform_now(city)
    end
  end

  desc 'Fetch service list/definitions for all cities, or list of individual cities'
  task :service_list, [:override] => :environment do |task, args|
    Rails.logger = Logger.new(STDOUT)
    overrides = Array(args[:override]) + Array(args.extras)

    if overrides.size > 0
      cities = overrides.map { |slug| City.find_by!(slug: slug) }
    else
      cities = City.all
    end

    cities.each do |city|
      FetchServiceListJob.perform_now(city)
    end
  end

  desc 'Delete service requests and statuses'
  task cleanup: :environment do |task, args|
    Status.where('created_at < ?', 48.hours.ago).find_each(&:destroy)
    ServiceRequest.where('created_at < ?', 48.hours.ago).find_each(&:destroy)
  end
end
