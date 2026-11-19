# frozen_string_literal: true

require Rails.root.join('config/flock')

# Builds the Vite assets once before the tests, instead of autoBuild on each request.
# https://mattbrictson.com/blog/faster-vite-test-without-autobuild
Flock.with_lock('vite-build', timeout: 60) do
  ViteRuby.commands.build
end
