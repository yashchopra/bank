class AddExternaluserapprovalToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :externaluserapproval, :integer
  end
end
