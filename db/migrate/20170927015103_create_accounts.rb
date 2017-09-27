class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :acctype
      t.string :accnumber
      t.string :accrouting
      t.integer :user_id

      t.timestamps
    end
  end
end
