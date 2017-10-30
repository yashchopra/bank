class AddTransactionOtpToTrans < ActiveRecord::Migration[5.1]
  def change
    add_column :trans, :transaction_otp, :string
  end
end
