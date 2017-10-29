class Tran < ApplicationRecord
  belongs_to :account
  enum credit: [:credit, :debit, :transfer, :request, :pay, :spend, :fee]
  enum status: [:pending, :approve, :decline]
  enum isCritical: [:true, :false]
  enum isEligibleForTier1: [:yes, :no]
  enum externaluserapproval: [:wait ,:accept, :reject]
  enum tier2_approval: [:impending,  :allow, :deny ]


  validates_presence_of :amount
  validate :amount_type
  validate :deductible_amount, :if => :transaction_type_is_transfer_or_debit?
  validate :cc_deductible_amount, :if => :transaction_type_is_pay_spend?


  validates_presence_of :transfer_account, :if => :transaction_type_is_transfer_or_request?
  validate :transfer_account_conditions, :if => :transaction_type_is_transfer_or_request?


  def amount_type
    if amount < 0
      errors.add(:amount, "invalid")
    end
  end

  def transaction_type_is_transfer_or_request?
    true if ["request", "transfer"].include? credit
  end

  def transaction_type_is_pay_spend?
    true if ["pay", "spend"].include? credit
  end

  def cc_deductible_amount
    current_acc = Account.find_by_id(account_id)
    last_transaction = current_acc.trans.where.not(balance: nil).last
    if last_transaction['id'] != id and (amount + last_transaction['balance']).ti_int > 2000 and credit != fee
      errors.add(:amount, "Your balance will exceed credit limit. Transaction cancelled")
    end
  end

  def transaction_type_is_transfer_or_request?
    true if ["pay", "spend"].include? credit
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

  def creditcard_interest
    cc_accounts = Account.where(acctype: 'Credit Card')
    cc_accounts.each do |account|
      if account[:statement_balance]
        fee_amount = statement_balance.to_int * 0.2
        Tran.create(:amount => fee_amount,
                    :credit => 'fee',
                    :balance => statement_balance + fee_amount,
                    :user_id => current_acc[:user_id],
                    :account_id => current_acc[:id],
                    :created_at => DateTime,
                    :updated_at => DateTime,
                    :transfer_account => @tran[:account_id])
        account.update_attributes(:statement_balance => statement_balance + fee_amount)
      end
    end
  end

  def try
    Rails.logger.info("CitrixIndex updated at #{Time.now}")
    puts "Yash%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
  end

end
