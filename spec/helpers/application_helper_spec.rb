require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#force_https' do
    it 'upgrades from http to https' do
      url = "http://example.com/something.png?key=value"
      expect(helper.force_https(url)).to eq "https://example.com/something.png?key=value"
    end
  end
end
