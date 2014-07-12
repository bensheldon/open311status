class CreateServiceRequests < ActiveRecord::Migration
  def change
    create_table :service_requests do |t|
      t.string :city_id
      t.string :service_request_id
      t.string :status

      t.column :raw_data, :json
      t.timestamps
    end

    add_index :service_requests, [:city_id, :service_request_id], unique: true
    add_index :service_requests, :status
  end
end
