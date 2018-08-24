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

class GlobalIndex < ApplicationRecord
  belongs_to :searchable, polymorphic: true
  belongs_to :service_request, foreign_type: 'Shirt', foreign_key: 'searchable_id'

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true)
  end

  def self.query(content)
    basic_search(content: content)
  end

  private

  def readonly?
    true
  end
end
