class CreateTrans < ActiveRecord::Migration[5.1]
  def change
    create_table :trans do |t|
      t.decimal :amount
      t.string :credit
      t.decimal :balance
      t.integer :user_id
      t.integer :account_id

      t.timestamps
    end
  end
end
