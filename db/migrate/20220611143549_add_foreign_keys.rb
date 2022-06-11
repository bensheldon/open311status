class AddForeignKeys < ActiveRecord::Migration[6.1]
  def change
    add_foreign_key :service_definitions, :cities, on_delete: :cascade, validate: false
    add_foreign_key :service_requests, :cities, on_delete: :cascade, validate: false
    add_foreign_key :statuses, :cities, on_delete: :cascade, validate: false
  end
end
