class AddSsnToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :ssn, :string
  end
end
