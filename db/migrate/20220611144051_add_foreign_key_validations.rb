class AddForeignKeyValidations < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :service_definitions, :cities
    validate_foreign_key :service_requests, :cities
    validate_foreign_key :statuses, :cities
  end
end
