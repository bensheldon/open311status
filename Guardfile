group :spec,
  halt_on_fail: true do

  guard :rspec,
    cmd: 'spring rspec --color --format documentation',
    all_after_pass: false,
    all_on_start: false,
    failed_mode: :none do

    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch('spec/spec_helper.rb')  { "spec" }

    # Rails example
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.erb|\.haml|\.slim)$})          { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
    watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
    watch('config/routes.rb')                           { "spec/routing" }
    watch('app/controllers/application_controller.rb')  { "spec/controllers" }

    # Capybara features specs
    watch(%r{^app/views/(.+)/.*\.(erb|haml|slim)$})     { |m| "spec/features/#{m[1]}_spec.rb" }
  end

  # included in rspec group for halt_on_fail:
  guard :rubocop,
        cli: ['--format', 'clang', '--rails'],
        all_on_start: false,
        keep_failed: false do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end
end

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)(/assets/\w+/(.+\.(css|js|html|png|jpg))).*}) { |m| "/assets/#{m[3]}" }
end
