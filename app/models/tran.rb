class Tran < ApplicationRecord
  belongs_to :account
  enum credit: [:credit, :debit, :transfer, :request, :pay, :spend]
  enum status: [:pending, :approve, :decline]
  enum isCritical: [:true, :false]
  enum isEligibleForTier1: [:true, :false]

  validates_presence_of :amount
  validate :amount_type
  validate :deductible_amount, :if => :transaction_type_is_transfer_or_debit?


  validates_presence_of :transfer_account, :if => :transaction_type_is_transfer_or_request?
  validate :transfer_account_conditions, :if => :transaction_type_is_transfer_or_request?


  def amount_type
    if amount <= 0
      errors.add(:amount, "invalid")
    end
  end

  def transaction_type_is_transfer_or_request?
    true if ["request", "transfer"].include? credit
  end

  def transaction_type_is_transfer_or_debit?
    true if ["debit", "transfer"].include? credit
  end

  def deductible_amount
    current_acc = Account.find_by_id(account_id)
    last_transaction = current_acc.trans.where.not(balance: nil).last
    if last_transaction['id'] != id and amount > last_transaction['balance']
      errors.add(:amount, "Amount can't be greater than your balance. Your current balance is #{last_transaction['balance']}")
    end
  end

  def transfer_account_conditions

    account_to_transfer_exist = (Account.exists?(accnumber: transfer_account) or (User.exists?(email: transfer_account)) or (User.exists?(phone: transfer_account)))
    if !account_to_transfer_exist
      errors.add(:transfer_account, "Account number / email / Phone number not found.")
    end

    if account_to_transfer_exist && transfer_himself
      errors.add(:transfer_account, "You can not send or recieve money from yourself")
    end

  end

  def transfer_himself
    same_account = false
    user_account = Account.find(account_id)
    user = User.find(user_account[:user_id])
    if transfer_account.include? '@'
      same_account = true if user[:email] == transfer_account
    elsif transfer_account.length == 10
      same_account = true if user[:phone] == transfer_account
    elsif transfer_account.length == 12
      same_account = true if user_account[:accnumber] == transfer_account
    end
    same_account
  end

end
