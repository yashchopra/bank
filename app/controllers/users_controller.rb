class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: :home


  def home
    if current_user.role == 'admin' or current_user.role == 'tier2' or current_user.role == 'tier1'
      redirect_to users_url and return
    elsif current_user.role == 'customer' or current_user.role == 'organization'
      redirect_to user_accounts_path(@current_user) and return
    end
  end

  def index
    @users = correct_user_list
    authorize User
  end

  def edit
  	@user = User.find(params[:id])
  	authorize @user
  end

  def destroy
    user = User.find(params[:id])
    authorize user
    user.destroy
    redirect_to users_url, :notice => "User deleted"
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize current_user

    respond_to do |format|
      if @user.save
        format.html {redirect_to users_url, notice: 'Tran was successfully created.'}
        format.json {render :show, status: :created, location: @tran_mod}
      else
        format.html {render :new}
        format.json {render json: @tran_mod.errors, status: :unprocessable_entity}
      end
    end
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    if @user.update_attributes(user_params)
      redirect_to user_accounts_path(@current_user), notice: 'User was successfully updated.'
      # format.json { render :show, status: :ok, location: @user }
    else
      redirect_to user_accounts_path(@current_user), notice: 'User update unsuccessfull'
      # format.json { render json: @account.errors, status: :unprocessable_entity }
    end
  end

  def user_params
    params.require(:user).permit(:role, :email, :password, :password_confirmation, :phone, :first_name, :last_name, :city, :state, :country, :street, :zip)
  end

  def correct_user_list
    if current_user.role == 'admin'
      @users = User.where(role: ["admin", "tier1", "tier2"])
    elsif current_user.role == 'tier1'
      @users = User.where(role: ["customer", "organization"])
    elsif current_user.role == 'tier2'
      @users = User.where(role: ["admin", "tier1", "tier2", "customer", "organization"])
    end
  end

end
