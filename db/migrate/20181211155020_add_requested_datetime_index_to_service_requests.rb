class AddRequestedDatetimeIndexToServiceRequests < ActiveRecord::Migration[5.2]
  def change
    add_index :service_requests, :requested_datetime, order: { requested_datetime: "DESC NULLS LAST" }
    add_index :service_requests, [:city_id, :requested_datetime], order: { requested_datetime: "DESC NULLS LAST" }
  end
end
