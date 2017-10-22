class AddStatusToTrans < ActiveRecord::Migration[5.1]
  def change
    add_column :trans, :status, :integer
  end
end
