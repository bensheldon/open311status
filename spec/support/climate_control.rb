# frozen_string_literal: true

module ClimateControlSupport
  def with_modified_env(options, &)
    ClimateControl.modify(options, &)
  end
end

RSpec.configure do |config|
  config.include ClimateControlSupport
end
