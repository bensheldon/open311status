RSpec.configure do |config|
  config.before(:all) do
    FactoryGirl.reload
  end
end
