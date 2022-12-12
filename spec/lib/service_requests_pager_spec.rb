# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServiceRequestsPager do
  let!(:service_requests) do
    (0...20).map do |i|
      create(:service_request, requested_datetime: Time.current - i.second)
    end
  end

  context 'when no points are provided' do
    it 'is at the very first page (reverse chronological)' do
      pager = described_class.new
      expect(pager.records.map(&:id)).to eq service_requests[0, 10].map(&:id)
      expect(pager.older?).to be true
      expect(pager.newer?).to be false
    end
  end

  context 'when before_id is provided' do
    it 'is in a middle page' do
      pager = described_class.new before_id: service_requests[9].id
      expect(pager.records.map(&:id)).to eq service_requests[10, 10].map(&:id)
      expect(pager.older?).to be false
      expect(pager.newer?).to be true
    end
  end

  it 'after_id is provided' do
    pager = described_class.new after_id: service_requests[10].id
    expect(pager.records.map(&:id)).to eq service_requests[0, 10].map(&:id)
    expect(pager.older?).to be true
    expect(pager.newer?).to be false
  end
end
