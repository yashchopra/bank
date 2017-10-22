class AddColumnsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :updated_email, :string
    add_column :users, :updated_phone, :string
    add_column :users, :status, :string
  end
end
