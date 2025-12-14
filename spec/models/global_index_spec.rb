# frozen_string_literal: true

# == Schema Information
#
# Table name: global_indices
#
#  id              :text
#  content         :text
#  searchable_type :text
#  searchable_id   :integer
#
# Indexes
#
#  index_global_indices_on_content_gist_trgm_ops        (content) USING gist
#  index_global_indices_on_id                           (id) UNIQUE
#  index_global_indices_on_to_tsvector_english_content  (to_tsvector('english'::regconfig, content)) USING gin
#
require 'rails_helper'

RSpec.describe GlobalIndex do
  let!(:request) { create(:service_request) }
  let!(:other_request) { create(:service_request) }

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
