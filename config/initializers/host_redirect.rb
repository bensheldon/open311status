Rails.application.config.middleware.use Rack::HostRedirect, {
  'open311status.herokuapp.com' => 'status.open311.org',
}

