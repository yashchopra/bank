class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

	has_many :accounts
	accepts_nested_attributes_for :accounts
	enum role: [:tier2, :tier1, :admin, :customer, :organization]
	after_initialize :set_default_role, :if => :new_record?

	validates_presence_of :first_name
	validates_presence_of :last_name
	validates_presence_of :city
	validates_presence_of :state
	validates_presence_of :country
	validates_presence_of :zip

	validates_presence_of :phone
	# validates_length_of :phone, 10


	def set_default_role  
		self.role ||= :customer
	end


  devise :database_authenticatable, :registerable, :recoverable, :trackable, :validatable, :two_factor_authenticatable, :lockable, :timeoutable
	has_one_time_password(encrypted: true)

	def send_two_factor_authentication_code(code)
		# Send code via SMS, etc.
		@code = code
		UserMailer.signup_confirmation(email, @code).deliver
	end

end
