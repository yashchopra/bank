class AddExternaluserapprovalToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :externaluserapproval, :integer
    add_column :accounts, :tier2_approval, :integer
  end
end
