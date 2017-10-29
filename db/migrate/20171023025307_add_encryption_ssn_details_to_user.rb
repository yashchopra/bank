class AddEncryptionSsnDetailsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :ssn_hash, :string
    add_column :users, :ssn_ciphertext, :string
  end
end
