# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'
require 'capybara/cuprite'

# Loads the Parklife output in ./build in a headless browser, served the way
# GitHub Pages serves it (`/about` is served from `about.html`).
# Run `bin/parklife build` first. Run with: bin/rspec --tag build
RSpec.describe 'Built static site', :build do # rubocop:disable RSpec/DescribeClass
  include Capybara::DSL

  let(:build_dir) { Rails.root.join('build') }

  def static_app(build_dir)
    lambda do |env|
      path = Rack::Utils.unescape_path(env['PATH_INFO']).delete_prefix('/').presence || 'index'
      file = [build_dir.join(path), build_dir.join("#{path}.html")].find(&:file?)
      if file
        [200, { 'content-type' => Rack::Mime.mime_type(file.extname, 'text/html') }, [file.binread]]
      else
        [404, { 'content-type' => 'text/html' }, [build_dir.join('404.html').read]]
      end
    end
  end

  # Count of elements matching a CSS selector, evaluated in the browser.
  def count(selector)
    page.evaluate_script("document.querySelectorAll(#{selector.to_json}).length")
  end

  def wait_for(selector)
    Timeout.timeout(5) { sleep 0.1 until count(selector).positive? }
    count(selector)
  rescue Timeout::Error
    0
  end

  around do |example|
    skip 'Run bin/parklife build first' unless build_dir.join('index.html').exist?

    Capybara.register_driver(:cuprite_build) do |app|
      # Only load local files: no analytics or remote request photos.
      Capybara::Cuprite::Driver.new(app, window_size: [1400, 900], js_errors: true, pending_connection_errors: false,
                                         url_allowlist: [%r{\Ahttp://127\.0\.0\.1}])
    end
    original = [Capybara.app, Capybara.current_driver, Capybara.server]
    Capybara.app = static_app(build_dir)
    Capybara.server = :puma, { Silent: true }
    Capybara.current_driver = :cuprite_build
    example.run
  ensure
    Capybara.reset_sessions!
    Capybara.app, Capybara.current_driver, Capybara.server = original
  end

  it 'draws the home page charts without JavaScript errors' do
    visit '/'
    expect(wait_for('[data-controller="line-chart"] canvas')).to eq 1
    expect(wait_for('[data-controller="sparkline"] canvas')).to eq count('[data-controller="sparkline"]')
  end

  it 'draws the chart on a city page linked from the home page' do
    visit '/'
    href = page.evaluate_script('document.querySelector("td strong a").getAttribute("href")')
    visit href
    expect(page.evaluate_script('document.querySelector("h1").textContent')).to be_present
    expect(wait_for('[data-controller="line-chart"] canvas')).to eq 1
  end

  it 'serves pages without the .html extension' do
    visit '/about'
    expect(page.evaluate_script('document.querySelector("h1").textContent')).to include('About Open311 Status')
  end
end
