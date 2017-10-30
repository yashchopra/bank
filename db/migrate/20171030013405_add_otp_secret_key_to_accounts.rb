class AddOtpSecretKeyToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :otp_secret_key, :string
  end
end
