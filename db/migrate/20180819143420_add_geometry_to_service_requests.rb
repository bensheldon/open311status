class AddGeometryToServiceRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :service_requests, :geometry, :geometry, geographic: true
    add_index :service_requests, :geometry, using: :gist
  end
end
