class Tran < ApplicationRecord
  belongs_to :account
  enum credit: [:credit, :debit, :transfer, :request, :pay, :spend, :fee]
  enum status: [:pending, :approve, :decline]
  enum isCritical: [:true, :false]
  enum isEligibleForTier1: [:yes, :no]
  enum externaluserapproval: [:wait, :accept, :reject]
  enum tier2_approval: [:impending, :allow, :deny]

#bizarre
  validates_presence_of :amount
  validate :amount_type
  validate :deductible_amount, :if => :transaction_type_is_transfer_or_debit?
  validate :cc_deductible_amount, :if => :transaction_type_is_pay_spend?


  validates_presence_of :transfer_account, :if => :transaction_type_is_transfer_or_request?
  validate :transfer_account_conditions, :if => :transaction_type_is_transfer_or_request?
  validate :transfer_account_cc_customer_conditions, :if => :transaction_type_is_transfer_or_request_only?


  def amount_type
    if amount < 0.0
      errors.add(:amount, "invalid")
    end
  end

  def transaction_type_is_transfer_or_request?
    true if ["request", "transfer", "pay", "spend"].include? credit
  end

  def transaction_type_is_pay_spend?
    true if ["pay", "spend"].include? credit
  end


  def transaction_type_is_transfer_or_request_only?
    true if ["request", "transfer"].include? credit
  end

  def cc_deductible_amount
    current_acc = Account.find_by_id(account_id)
    last_transaction = current_acc.trans.where.not(balance: nil).last
    if last_transaction['id'] != id and (amount + last_transaction['balance']).to_int > 2000.00 and credit != 'fee'
      errors.add(:amount, "Your balance will exceed credit limit. Transaction cancelled")
    end
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

    if account_to_transfer_exist && transfer_himself
      errors.add(:transfer_account, "You can not send or recieve money from yourself")

    elsif account_to_transfer_exist && !transfer_himself
      if transfer_account.include? '@'
        checking_chck = (User.find_by_email(transfer_account)).accounts.find_by_acctype('checking')
        if checking_chck == nil
          errors.add(:transfer_account, "Email transfers can only be done to Checking accounts")
        else
          account_to_transfer = checking_chck.accnumber
          self.transfer_account = account_to_transfer
        end
      elsif transfer_account.length == 10
        checking_chck = (User.find_by_phone(transfer_account)).accounts.find_by_acctype('checking')
        if checking_chck == nil
          errors.add(:transfer_account, "Phone transfers can only be done to Checking accounts")
        else
          account_to_transfer = checking_chck.accnumber
          self.transfer_account = account_to_transfer
        end
      elsif transfer_account.length == 12
        account_to_transfer = transfer_account
        self.transfer_account = account_to_transfer
      end

    elsif !account_to_transfer_exist
      errors.add(:transfer_account, "Account number / email / Phone number not found.")
    end
  end

  def transfer_account_cc_customer_conditions
    account_to_transfer_exist = (Account.exists?(accnumber: transfer_account) or (User.exists?(email: transfer_account)) or (User.exists?(phone: transfer_account)))
    if account_to_transfer_exist and User.find_by_id(Account.find_by(:id => account_id)[:user_id])[:role] == 'customer' and transfer_account.length == 16 and transfer_account.include?("4223")
      errors.add(:transfer_account, 'Customer is not allowed to send/request money from Credit card')
    else account_to_transfer_exist and User.find_by_id(Account.find_by(:id => account_id)[:user_id])[:role] == 'organization' and transfer_account.length == 16 and transfer_account.include?("4223")
      transfer_acc = Account.find_by(:accnumber => transfer_account)
      errors.add(:transfer_account, "CVV not matched") unless transfer_acc[:accrouting] == routingNum
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


  def try
    Rails.logger.info("CitrixIndex updated at #{Time.now}")
  end

end
