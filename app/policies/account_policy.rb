class AccountPolicy
  attr_reader :current_user, :model
  
  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
    @current_user.tier1?
  end

  def new?
    @current_user.tier1? || @current_user == @user
  end

  def show?
    @current_user.tier1? || @current_user == @user
  end

  def edit?
    @current_user.tier1? || @current_user == @user
  end

  def update?
    @current_user.tier1?
  end

end
