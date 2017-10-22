class UserPolicy
	attr_reader :current_user, :model

	def initialize(current_user, model)
		@current_user = current_user
		@user = model
	end

	def destroy?
		return false if @current_user == @user
		@current_user.admin? || @current_user.tier1? || @current_user.tier2?
	end

	def new?
		@current_user.admin? || @current_user.tier1?
	end

	def index?
		@current_user.admin? || @current_user.tier1? || @current_user.tier2?
	end

	def show?
		@current_user.admin? || @current_user.tier1? || @current_user.tier2?
	end

	def edit?
		@current_user == @user
	end

	def log?
    @current_user.admin?
	end

	def update?
		@current_user.admin? || @current_user.tier1? || @current_user.tier2? || @current_user == @user
	end

	def create?
		@current_user.admin? || @current_user.tier1? || @current_user.tier2?
	end
end
