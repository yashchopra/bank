class ChangeStatusFormatInUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :status, :integer
  end
end
