class ChangeCreditFormatInTrans < ActiveRecord::Migration[5.1]
  # def change
  # end

  def up
    change_column :trans, :credit, :integer
  end

  def down
    change_column :trans, :credit, :string
  end
end
