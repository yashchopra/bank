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
      if user_params[:status].present?
        user_params = check_status_function
        redirect_to user_accounts_path(@current_user), notice: 'Changes acknoledged'
      elsif user_params[:updated_email].nil? || user_params[:updated_phone] != nil
        user_params[:status] = 'pending'
        redirect_to user_accounts_path(@current_user), notice: 'Your information is sent for approval'
      else
        redirect_to user_accounts_path(@current_user), notice: 'User was successfully updated.'
      end
    else
      redirect_to user_accounts_path(@current_user), notice: 'User update unsuccessfull'
      # format.json { render json: @account.errors, status: :unprocessable_entity }
    end
  end


  def user_params
    params.require(:user).permit(:role, :email, :password, :password_confirmation, :phone, :first_name, :last_name, :city, :state, :country, :street, :zip, :updated_email, :updated_phone, :status)
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


  def check_status_function
    if user_params[:status] == 'approve'
      if user_params[:updated_email] != nil
        user_params[:email] = user_params[:updated_email]

      end
      if user_params[:updated_phone] != nill
        user_params[:phone] = user_params[:updated_phone]
      end
    elsif user_params[:status] == 'declined'
      user_params[:updated_phone] = user_params[:updated_email] = nil
      user_params[:status] = nil
    end
    user_params
  end

end
