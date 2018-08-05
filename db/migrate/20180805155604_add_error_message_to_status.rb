class AddErrorMessageToStatus < ActiveRecord::Migration[5.2]
  def change
    add_column :statuses, :error_message, :text
  end
end
