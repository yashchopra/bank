class Account < ApplicationRecord
  has_one_time_password
  belongs_to :user
  has_many :trans, dependent: :destroy
  accepts_nested_attributes_for :trans
  before_save :set_account_number
  validate :number_of_accounts
  validate :all_the_inputs
  enum externaluserapproval: [:wait ,:accept, :reject]
  enum tier2_approval: [:impending,  :allow, :deny ]

  def generateOTP
    self.otp_code = Account.otp_code
  end

  private

  def set_account_number
    if acctype == "Credit Card"
      self.accnumber = get_unique_credit_card_number
      self.accrouting = get_unique_cvv_number
    else
      acc_number = get_unique_acc_number
      self.accnumber = acc_number
      self.accrouting = '100011000'
    end
  end

  def get_unique_acc_number
    not_unique = true
    while not_unique
      acc_num = rand.to_s[-12..-1]
      not_unique = Account.exists?(accnumber: acc_num)
    end
    acc_num
  end

  def get_unique_credit_card_number
    not_unique = true
    while not_unique
      credit_card_number = rand.to_s[-12..-1]
      credit_card_number = '4223' << credit_card_number
      not_unique = Account.exists?(accnumber: credit_card_number)
    end
    credit_card_number
  end

  def get_unique_cvv_number
    not_unique = true
    while not_unique
      cvv_number = rand.to_s[-3..-1]
      not_unique = Account.exists?(accnumber: cvv_number)
    end
    cvv_number
  end

  def number_of_accounts
    if user.accounts.all.length > 3
      errors.add(:acctype, "Only 3 accounts allowed.")
    end
  end

  def all_the_inputs
    if user[:role] == "customer" && (!['Checking', 'Savings', 'Credit Card'].include? self[:acctype])
      errors.add(:acctype, "Invalid input")
    elsif user[:role] == "organization" && (!['Checking'].include? self[:acctype])
    end
    if self[:user_id] != user[:id]
      errors.add(:user_id, "Invalid input")
    end
  end

end
