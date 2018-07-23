class CreateServiceRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :service_requests do |t|
      t.string :service_request_id
      t.string :status
      t.datetime :requested_datetime
      t.datetime :updated_datetime

      t.column :raw_data, :json
      t.timestamps
    end

    add_reference :service_requests, :city, index: true

    add_index :service_requests, [:city_id, :service_request_id], unique: true
    add_index :service_requests, :status
  end
end
