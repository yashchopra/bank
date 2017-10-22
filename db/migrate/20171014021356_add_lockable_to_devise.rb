class AddLockableToDevise < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :unlock_token, unique: true
  end
end
