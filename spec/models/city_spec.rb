require 'rails_helper'

RSpec.describe City, :type => :model do
  it 'has a valid factory' do
    FactoryGirl.create :test_city
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
