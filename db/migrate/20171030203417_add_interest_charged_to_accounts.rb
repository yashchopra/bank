class AddInterestChargedToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :interest_charged, :boolean
  end
end
