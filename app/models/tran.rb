class Tran < ApplicationRecord
  belongs_to :account
  enum credit: [:credit, :debit, :transfer, :request]
  enum status: [:pending, :approve, :decline]

  # validates_presence_of :amount
  # before_create :deductible_amount, :if => :transaction_type_is_transfer_or_debit?
  # before_validation :transfer_account_present, :if => :transaction_type_is_transfer?

  # def transaction_type_is_transfer_or_debit?
  #   true if credit == ("debit" or "transfer")
  # end
  #
  # def deductible_amount
  #   last_transaction = Tran.where(account_id.to_s).last.as_json
  #   if last_transaction['id'] != id and amount > last_transaction['balance']
  #     errors.add(:amount, "Amount can't be greater than your balance. Your current balance is #{last_transaction['balance']}")
  #   end
  # end
  #
  # def transaction_type_is_transfer?
  #   true if credit == 'transfer'
  # end

  # def transfer_account_present
  #   if transfer_account.present?
  #     @account =  Account.where(accnumber: transfer_account)
  #     # .or (USER.where(email: transfer_account))
  #     if !@account
  #       errors.add(:transfer_account, "Account number / email / Phone number not found.")
  #     end
  #   else
  #     errors.add(:transfer_account, "Account number / email / Phone number can not be blank")
  #   end
  # end

end
