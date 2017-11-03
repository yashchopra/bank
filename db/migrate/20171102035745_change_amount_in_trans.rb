class ChangeAmountInTrans < ActiveRecord::Migration[5.1]
  def change
    change_column :trans, :amount, :decimal, :precision => 10, :scale => 2
  end
end
