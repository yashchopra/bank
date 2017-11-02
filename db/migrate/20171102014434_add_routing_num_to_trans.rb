class AddRoutingNumToTrans < ActiveRecord::Migration[5.1]
  def change
    add_column :trans, :routingNum, :string
  end
end
