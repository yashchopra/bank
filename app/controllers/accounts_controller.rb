class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  before_action :set_user

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = @user.accounts.all
    # @accounts = Account.all
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    @trans = @account.trans.all
    respond_to do |format|
      format.pdf do
        render :pdf => 'Account_Statement',
               :disposition => 'attachment',
               :template => "accounts/show.pdf.erb"

      end

      format.html
    end
  end
  def download
    html = render_to_string(:action => :show)
    pdf = WickedPdf.new.pdf_from_string(html)

    send_data(pdf,
              :filename => 'testpdf.pdf',
              :disposition => 'attachment')
  end
  # GET /accounts/new
  def new
    @account = @user.accounts.new
    if @user.organization?
      @account_types = ['Checking']
      @acc_counter = 1
    else
      @account_types = ['Checking','Savings','Credit Card']
      @acc_counter = 3
    end

    @user.accounts.all.pluck(:acctype).each do |type|
      @account_types.delete(type)
      @acc_counter = @acc_counter - 1
    end
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = @user.accounts.create(account_params)
    # @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to user_account_path(current_user, @account), notice: 'Account was successfully created.' }
        format.json { render :show, status: :created, location: @account }
      else
        format.html { render :new }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end

      add_initial_ammount(account_params)

  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to user_account_path(@user, @account), notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to user_accounts_path(@user), notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    def set_user
      if current_user.admin? or current_user.tier2?
        redirect_to users_url
      elsif current_user.customer? or current_user.organization?
        @user = current_user
      elsif current_user.tier1?
        @user = User.find(params[:user_id])
        # @user = @account.user_id
      end
    end

  def add_initial_ammount(account_params)
    if @account[:acctype] != "Credit Card"
    Tran.create(:amount => 2000,
                :credit => 'credit',
                :balance => 2000,
                :user_id => @user.id,
                :account_id => @account.id,
                :created_at => DateTime,
                :updated_at => DateTime,
                :transfer_account => 'Initial Amount')
    else
      Tran.create(:amount => 0,
                  :credit => 'credit',
                  :balance => 0,
                  :user_id => @user.id,
                  :account_id => @account.id,
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => 'Initial Amount')
      end
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:acctype, :accnumber, :accrouting, :user_id)
    end
end
