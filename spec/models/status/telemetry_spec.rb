require 'rails_helper'

RSpec.describe Status::Telemetry do
  let(:city) { Cities::SanFrancisco.instance }
  describe '.process' do
    it 'coerces open311 exceptions to status' do
      result = described_class.process('service_list', city: city) do
        raise Open311::BadRequest
      end

      status = Status.last
      expect(result).to be nil
      expect(status.city).to eq city
      expect(status.http_code).to eq 400
    end
  end
end