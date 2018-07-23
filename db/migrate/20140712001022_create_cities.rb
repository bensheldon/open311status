class CreateCities < ActiveRecord::Migration[5.1]
  def change
    create_table :cities do |t|
      t.string :slug

      t.timestamps
    end

    add_index :cities, :slug, unique: true
  end
end
