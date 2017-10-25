class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:home]


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
      if verify_recaptcha(model: @user) && @user.save
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

    if verify_recaptcha(model: @user) && @user.update_attributes(user_params)
      updated_user_params = user_params
      if user_params['status']
        check_status_function
      elsif user_params['updated_email'] or user_params['updated_phone']
        @user.update_attributes(:status => 'pending')
      end
      redirect_to user_accounts_path(@current_user), notice: 'User was successfully updated.' and return
    else
      redirect_to user_accounts_path(@current_user), notice: 'User update unsuccessfull' and return
    end
  end

  def log
    @user = current_user
    authorize @user

    lines = params[:lines]
    if Rails.env == "production"
      @logs = `tail -n #{lines} log/production.log`
    else
      @logs = `tail -n #{lines} log/development.log`
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
    if user_params['status'] == 'approve'
      if @user[:updated_email]
        @user.update_attributes(:email => @user[:updated_email], :updated_email => nil)
        # @user[:updated_email] = nil
      end
      if @user[:updated_phone]
        @user.update_attributes(:phone => @user[:updated_phone], :updated_phone => nil)
        # @user[:phone] = @user[:updated_phone]
      end
    elsif user_params['status'] == 'declined'
      @user.update_attributes(:updated_email => nil, :updated_phone => nil)
      # @user[:updated_phone] = @user[:updated_email] = nil
      user_params['status'] = nil
    end
    user_params
  end

end

