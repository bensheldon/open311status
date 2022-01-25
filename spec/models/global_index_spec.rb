# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GlobalIndex, type: :model do
  let!(:request) { create :service_request }
  let!(:other_request) { create :service_request }

  describe '#query' do
    describe 'ServiceRequests' do
      it 'searches by description' do
        refresh_materialized_view

        result = described_class.query(request.raw_data['description']).map(&:searchable)
        expect(result).to eq [request]
      end
    end
  end

  def refresh_materialized_view
    described_class.refresh
    yield if block_given?
  end
end
