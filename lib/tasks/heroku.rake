# frozen_string_literal: true
namespace :heroku do
  desc 'Heroku release tasks (runs on every code push, before postdeploy task on review app creation)'
  task release: :environment do
    if ActiveRecord::SchemaMigration.table_exists?
      Rake::Task['db:migrate'].invoke
      Rake::Task['cities:load'].invoke
    else
      Rails.logger.info "Database not initialized, skipping database tasks"
    end
  end

  desc 'Heroku postdeploy tasks (runs only on review app creation, after release task)'
  task postdeploy: :environment do
    Rake::Task['db:schema:load'].invoke
    Rake::Task['cities:load'].invoke
    Rake::Task['db:seed'].invoke
  end
end
