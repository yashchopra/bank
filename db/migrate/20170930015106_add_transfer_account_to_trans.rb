class AddTransferAccountToTrans < ActiveRecord::Migration[5.1]
  def change
    add_column :trans, :transfer_account, :string
  end
end
