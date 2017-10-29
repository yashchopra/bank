class AddExternaluserapprovalToTrans < ActiveRecord::Migration[5.1]
  def change
    add_column :trans, :externaluserapproval, :integer
  end
end
