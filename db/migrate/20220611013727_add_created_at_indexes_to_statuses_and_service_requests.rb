class AddCreatedAtIndexesToStatusesAndServiceRequests < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :statuses, :created_at, algorithm: :concurrently
    add_index :service_requests, :created_at, algorithm: :concurrently
  end
end
