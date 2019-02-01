# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Seeder do
  let(:seeder) { described_class.new }

  describe '#call' do
    it 'creates new records' do
      expect { seeder.call }.to change(ServiceRequest, :count).from(0)
    end
  end
end
