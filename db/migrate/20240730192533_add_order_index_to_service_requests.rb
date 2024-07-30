class AddOrderIndexToServiceRequests < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :service_requests, [:city_id, :created_at, :id], algorithm: :concurrently
  end
end
