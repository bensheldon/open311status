# frozen_string_literal: true

require 'capybara/cuprite'

Capybara.server = :puma, { Silent: true }

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1400, 900],
    process_timeout: 10,
    inspector: ENV['INSPECTOR'].present?,
    headless: !ENV['HEADLESS'].in?(%w[n 0 no false]),
    # The cities page holds open a Turbo/Action Cable WebSocket, which Ferrum
    # otherwise treats as a "pending connection" and raises on page load.
    pending_connection_errors: false
  )
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by :cuprite
  end
end
