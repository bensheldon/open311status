RSpec.describe Seeder do
  let(:seeder) { described_class.new }

  around do |example|
    ActiveRecord::Base.transaction do
      example.run

      raise ActiveRecord::Rollback
    end
  end

  describe '#call' do
    it 'creates new records' do
      expect { seeder.call }.to change { ServiceRequest.count }.from(0)
    end
  end
end
