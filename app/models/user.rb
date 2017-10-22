class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

	has_many :accounts
	accepts_nested_attributes_for :accounts
	enum role: [:tier2, :tier1, :admin, :customer, :organization]
	after_initialize :set_default_role, :if => :new_record?
  
	def set_default_role  
		self.role ||= :customer
	end


  devise :database_authenticatable, :registerable, :recoverable, :trackable, :validatable, :two_factor_authenticatable, :lockable, :timeoutable, :password_expirable, :secure_validatable
	has_one_time_password(encrypted: true)

	def send_two_factor_authentication_code(code)
		# Send code via SMS, etc.
		@code = code
		UserMailer.signup_confirmation(email, @code).deliver
	end

end
