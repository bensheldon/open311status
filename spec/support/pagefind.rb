# frozen_string_literal: true

require Rails.root.join('config/flock')
require Rails.root.join('config/pagefind')

module PagefindHelpers
  # Builds the search index from the test data into public/pagefind.
  # The lock stops parallel test processes from writing the index at the same time.
  def build_search_index
    Flock.with_lock('pagefind-build', timeout: 60) { Pagefind.build }
  end
end

RSpec.configure do |config|
  config.include PagefindHelpers, type: :system
end
