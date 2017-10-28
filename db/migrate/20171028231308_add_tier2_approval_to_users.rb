class AddTier2ApprovalToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :tier2_approval, :integer
  end
end
