# frozen_string_literal: true

require 'uri'

RSpec.shared_examples 'a city' do
  let(:city) { described_class.instance }

  describe '#name' do
    it 'is a non-empty string' do
      expect(city.name).to a_kind_of String
      expect(city.name.size).to be > 3
    end
  end

  describe '#endpoint' do
    it 'is valid URL' do
      expect(city.endpoint).to match URI::DEFAULT_PARSER.make_regexp
    end
  end
end
