# frozen_string_literal: true
namespace :db do
  desc 'If database exists, run migrations; otherwise load schema'
  task load_schema_or_migrate: :environment do
    if ActiveRecord::SchemaMigration.table_exists?
      Rake::Task['db:migrate'].invoke
    else
      Rake::Task['db:schema:load'].invoke
    end
  end
end
