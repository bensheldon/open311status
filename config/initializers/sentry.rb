Raven.configure do |config|
  config.environments = %w[ production ]
end

Raven.tags_context({
  'environment' => Rails.env
})
