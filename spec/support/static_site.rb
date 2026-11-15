# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/cuprite'

# Serves the Parklife output in ./build the way GitHub Pages does:
# `/` is `index.html`, and `/about` is `about.html`.
class StaticSite
  def initialize(root)
    @root = Pathname.new(root)
  end

  def call(env)
    path = Rack::Utils.unescape_path(env['PATH_INFO']).delete_prefix('/').presence || 'index'
    file = [@root.join(path), @root.join("#{path}.html")].find(&:file?)
    return [404, { 'content-type' => 'text/html' }, [@root.join('404.html').read]] unless file

    [200, { 'content-type' => Rack::Mime.mime_type(file.extname, 'text/html') }, [file.binread]]
  end
end

Capybara.register_driver(:cuprite_offline) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1400, 900],
    js_errors: true,
    # Resolve every host except 127.0.0.1 to "not found", so tests make no external requests.
    browser_options: { 'host-resolver-rules' => 'MAP * ~NOTFOUND, EXCLUDE 127.0.0.1' }
  )
end

RSpec.configure do |config|
  # Specs tagged :build run against ./build, and only with `--tag build`.
  config.filter_run_excluding :build unless config.inclusion_filter[:build]

  config.around(:each, :build) do |example|
    build_dir = Rails.root.join('build')
    skip 'Run bin/parklife build first' unless build_dir.join('index.html').exist?

    original_app = Capybara.app
    Capybara.app = StaticSite.new(build_dir)
    Capybara.current_driver = :cuprite_offline
    example.run
  ensure
    Capybara.reset_sessions!
    Capybara.use_default_driver
    Capybara.app = original_app
  end
end
