class AddLockableToDevise < ActiveRecord::Migration[5.0]
  def change
<<<<<<< HEAD
    # add_column :users, :failed_attempts, :integer, default: 0, null: false # Only if lock strategy is :failed_attempts
    # add_column :users, :unlock_token, :string # Only if unlock strategy is :email or :both
    # add_column :users, :locked_at, :datetime
    # add_index :users, :unlock_token, unique: true
=======
    add_index :users, :unlock_token, unique: true
>>>>>>> 2d2e016570bbef842eb8b1d6c84c0960b453eb42
  end
end
