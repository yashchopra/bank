class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

	has_many :accounts
	accepts_nested_attributes_for :accounts
	enum role: [:tier2, :tier1, :admin, :customer, :organization]
	enum status: [:pending, :approve, :decline]
	after_initialize :set_default_role, :if => :new_record?

	# validates_presence_of :first_name
	# validates_presence_of :last_name
	# validates_presence_of :city
	# validates_presence_of :state
	# validates_presence_of :country
	# validates_presence_of :zip
  #
	# validates_presence_of :phone


	def set_default_role  
		self.role ||= :customer
	end


<<<<<<< HEAD
  devise :database_authenticatable, :recoverable, :trackable, :validatable, :two_factor_authenticatable, :lockable, :timeoutable
=======
  devise :database_authenticatable, :registerable,:session_limitable, :recoverable, :trackable, :validatable, :two_factor_authenticatable, :lockable, :timeoutable
>>>>>>> 2d2e016570bbef842eb8b1d6c84c0960b453eb42
	has_one_time_password(encrypted: true)

	def send_two_factor_authentication_code(code)
		# Send code via SMS, etc.
		@code = code
		UserMailer.signup_confirmation(email, @code).deliver
	end

end
