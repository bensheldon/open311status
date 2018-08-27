class RemoveStatusesIndexOnCityAndRequest < ActiveRecord::Migration[5.2]
  def change
    remove_index :statuses, :city_id
    remove_index :statuses, [:city_id, :request_name]
  end
end
