class IndexMostRecentStatus < ActiveRecord::Migration[5.2]
  def change
    add_index :statuses, [:city_id, :request_name, :created_at], order: { created_at: :desc }
  end
end
