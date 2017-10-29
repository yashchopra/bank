class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

	has_many :accounts
	accepts_nested_attributes_for :accounts
	enum role: [:tier2, :tier1, :admin, :customer, :organization]
	enum status: [:pending, :approve, :decline]
	after_initialize :set_default_role, :if => :new_record?
	enum isEligibleForTier1: [:yes, :no]
	enum externaluserapproval: [:accept, :reject]
	enum tier2_approval: [:allow, :deny ]

  encrypt :ssn, searchable: true, hash_salt: ENV["SECRET_KEY_BASE"], key: ENV["SECRET_KEY_BASE"]
  #
	# validates_presence_of :first_name
	# validates_presence_of :last_name
	# validates_presence_of :city
	# validates_presence_of :state
	# validates_presence_of :country
  #
	# validates :zip, :presence => true,
	# 					      :numericality => true,
	# 							  :length => {:minimum => 1}
  #
	# validates :phone,:presence => true,
	# 					:numericality => true,
	# 					:length => { :minimum => 10, :maximum => 10 }

	# validates :ssn,:presence => true,
	#  					:numericality => true,
	#  					:length => { :minimum => 9, :maximum => 9 }


	def set_default_role  
		self.role ||= :customer
	end


  devise :database_authenticatable, :recoverable, :trackable, :validatable, :two_factor_authenticatable, :lockable, :timeoutable, :password_expirable, :secure_validatable
	has_one_time_password(encrypted: true)

	def send_two_factor_authentication_code(code)
		# Send code via SMS, etc.
		@code = code
		UserMailer.signup_confirmation(email, @code).deliver
	end

end
