class CreateServiceDefinitions < ActiveRecord::Migration[5.1]
  def change
    create_table :service_definitions do |t|
      t.references :city, index: true
      t.string :service_code
      t.json :raw_data

      t.timestamps
    end

    add_index :service_definitions, [:city_id, :service_code]
  end
end
