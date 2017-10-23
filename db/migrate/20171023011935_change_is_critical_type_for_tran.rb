class ChangeIsCriticalTypeForTran < ActiveRecord::Migration[5.1]
  def change
    change_column(:trans, :isCritical, :integer)
    change_column(:trans, :isEligibleForTier1, :integer)
  end
end
