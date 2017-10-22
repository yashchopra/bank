class AddColumnsToTrans < ActiveRecord::Migration[5.1]
  def change
    add_column :trans, :isCritical, :boolean
    add_column :trans, :isEligibleForTier1, :boolean
  end
end
