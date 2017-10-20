class Account < ApplicationRecord
  belongs_to :user
  has_many :trans, dependent: :delete_all
  accepts_nested_attributes_for :trans
  before_save :set_account_number
  validate :number_of_accounts
  validate :all_the_inputs

  private

  def set_account_number
    acc_number = get_unique_acc_number
    self.accnumber = acc_number
    self.accrouting = '100011000'
  end

  def get_unique_acc_number
    not_unique = true
    while not_unique
      acc_num = rand.to_s[-12..-1]
      not_unique = Account.exists?(accnumber: acc_num)
    end
    acc_num
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
