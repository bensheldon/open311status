class CreateGlobalIndices < ActiveRecord::Migration[5.2]
  def change
    enable_extension "pg_trgm"
    create_view :global_indices, materialized: true
    add_index :global_indices, :id, unique: true
    add_index :global_indices, "to_tsvector('english', content)", using: :gin
    add_index :global_indices, "content gist_trgm_ops", using: :gist
  end
end
