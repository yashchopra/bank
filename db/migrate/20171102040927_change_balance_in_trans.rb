class ChangeBalanceInTrans < ActiveRecord::Migration[5.1]
  def change
    change_column :trans, :balance, :decimal, :precision => 10, :scale => 2
  end
end
