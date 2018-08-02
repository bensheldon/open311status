if Rails.env.development? || Rails.env.test?
  color = :green
else
  color = :red
end

old_prompt = Pry.config.prompt
env = Pry::Helpers::Text.send(color, Rails.env.upcase)

Pry.config.prompt = [
  proc {|*a| "#{env} #{old_prompt.first.call(*a)}"},
  proc {|*a| "#{env} #{old_prompt.second.call(*a)}"},
]
