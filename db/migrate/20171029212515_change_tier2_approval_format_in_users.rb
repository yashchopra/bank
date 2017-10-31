class ChangeTier2ApprovalFormatInUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :tier2_approval, :string
    change_column :users, :externaluserapproval, :string
  end
end
