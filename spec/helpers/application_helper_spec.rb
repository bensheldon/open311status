require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#force_https' do
    it 'upgrades from http to https' do
      url = "http://example.com/something.png?key=value"
      expect(helper.force_https(url)).to eq "https://example.com/something.png?key=value"
    end
    
    it 'does not upgrade incomplete urls' do
      url = '/just/a/path'
      expect(helper.force_https(url)).to eq url
    end
  end

  describe 'valid_url?' do
    it 'returns false if just a path' do
      url = "http://example.com/something.png?key=value"
      expect(helper.valid_url?(url)).to eq true
    end

    it 'returns true if a full url' do
      url = '/just/a/path'
      expect(helper.valid_url?(url)).to eq false
    end

    it 'returns false if not a string' do
      url = nil
      expect(helper.valid_url?(url)).to eq false
    end
  end
end
