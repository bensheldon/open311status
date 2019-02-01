# frozen_string_literal: true
namespace :db do
  namespace :views do
    desc 'Refresh materialized views'
    task refresh: :environment do |_t, _args|
      GlobalIndex.refresh
      $stdout.puts "Refreshed materialized views."
    end
  end
end
