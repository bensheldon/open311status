class AddServiceDefinitionsCountToCities < ActiveRecord::Migration[5.2]
  def change
    add_column :cities, :service_definitions_count, :integer, default: 0, null: false

    reversible do |direction|
      direction.up do
        City.find_each do |city|
          City.reset_counters city.id, :service_definitions
        end
      end
    end
  end
end
