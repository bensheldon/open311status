# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoodJob do
  describe '.migrated?' do
    it 'has all migrations applied' do
      expect(described_class.migrated?).to be true
    end
  end
end
