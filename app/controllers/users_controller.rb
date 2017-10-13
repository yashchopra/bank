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

	# def show
	# 	@user = User.find(params[:id])
	# 	authorize @user
	# end

	def destroy
		user = User.find(params[:id])
		authorize user
		user.destroy
		redirect_to users_url, :notice => "User deleted"
	end

	# def edit
	# 	authorize User
	# 	@users = User.all
	# end

	def update
		@user = User.find(params[:id])
		authorize @user

		if @user.update_attributes(user_params)
        redirect_to users_path, notice: 'User was successfully updated.'
        # format.json { render :show, status: :ok, location: @user }
      else
      	redirect_to users_path, notice: 'User update unsuccessfull'
        # format.json { render json: @account.errors, status: :unprocessable_entity }
      end
	end

	def user_params
		params.require(:user).permit(:role, :email)
	end

	def correct_user_list
		if current_user.role == 'admin'
			@users = User.where(role: ["admin", "tier1", "tier2"])
		elsif current_user.role == 'tier1'
			@users = User.where(role: ["customer", "organization"])
		elsif current_user.role == 'tier2'
			@users = User.where(role: ["admin", "tier1", "tier2","customer", "organization"])
		end
	end

end
