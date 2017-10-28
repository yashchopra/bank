class AddStatementBalanceToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :statement_balance, :integer
  end
end
