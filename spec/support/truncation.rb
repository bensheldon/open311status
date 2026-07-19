# frozen_string_literal: true

# Tag a spec `:truncation` when it needs data to be really committed instead
# of rolled back by the default transactional-fixtures strategy — e.g. to
# observe a Postgres `LISTEN`/`NOTIFY`-based Action Cable broadcast, which
# Postgres only delivers to listeners once the issuing transaction commits.
# Cleans up afterward by truncating every table, since nothing will be
# rolled back automatically.
module TruncationHelpers
  def self.included(example_group)
    example_group.use_transactional_tests = false
  end
end

RSpec.configure do |config|
  config.include TruncationHelpers, truncation: true

  config.after(:each, :truncation) do
    connection = ActiveRecord::Base.connection
    tables = connection.tables - %w[schema_migrations ar_internal_metadata]
    quoted_tables = tables.map { |table| connection.quote_table_name(table) }.join(', ')

    connection.execute("TRUNCATE TABLE #{quoted_tables} RESTART IDENTITY CASCADE")
  end
end
