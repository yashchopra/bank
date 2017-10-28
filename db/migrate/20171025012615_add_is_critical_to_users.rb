class AddIsCriticalToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :isCritical, :integer
    add_column :users, :isEligibleForTier1, :integer
  end
end
