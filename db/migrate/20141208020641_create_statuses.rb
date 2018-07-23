class CreateStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :statuses do |t|
      t.references :city, index: true
      t.string :request_name
      t.integer :duration_ms
      t.integer :http_code

      t.datetime :created_at
    end

    add_index :statuses, [:city_id, :request_name]
  end
end
