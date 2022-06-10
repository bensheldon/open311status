# frozen_string_literal: true

def formatted_env
  if Rails.env.production?
    bold_env = Pry::Helpers::Text.bold(Rails.env)
    Pry::Helpers::Text.red(bold_env)
  elsif Rails.env.development?
    Pry::Helpers::Text.green(Rails.env)
  else
    Rails.env
  end
end

Pry::Prompt.add 'project_custom', "Includes the current Rails environment.", %w(> *) do |target_self, nest_level, _pry, sep|
  "[#{formatted_env}] " \
    "(#{Pry.view_clip(target_self)})" \
    "#{":#{nest_level}" unless nest_level.zero?}#{sep} "
end

Pry.config.prompt = Pry::Prompt.all['project_custom']
