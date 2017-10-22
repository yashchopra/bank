class TransController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tran, only: [:show, :edit, :update, :destroy]
  before_action :set_account

  # GET /trans
  # GET /trans.json
  def index
    if current_user.tier1?
      @trans = Tran.where(status: 'pending')
      @user = User.where(role: 'customer').or(User.where(role: 'organization'))
    else
      user_not_authorized and return
    end
    if current_user.tier1?
      @users_to_be_approved = User.where(status: 'pending')
    end
  end

  # GET /trans/1
  # GET /trans/1.json
  # def show
  # end

  # GET /trans/new
  def new
    # @tran = Tran.new
    @tran = @account.trans.new
  end

  ``
  # GET /trans/1/edit
  # def edit
  # end

  # POST /trans
  # POST /trans.json
  def create
    @tran = @account.trans.create(tran_params)

    respond_to do |format|
      @tran = do_transaction_specific_calculations
      if @tran.save
        format.html {redirect_to user_account_path(@user, @account), notice: 'Tran was successfully created.'}
        format.json {render :show, status: :created, location: @tran_mod}
      else
        format.html {render :new}
        format.json {render json: @tran_mod.errors, status: :unprocessable_entity}
      end
    end
  end

  # PATCH/PUT /trans/1
  # PATCH/PUT /trans/1.json
  def update
    @tran = Tran.find(params[:id])
    respond_to do |format|
      if @tran.update(tran_params)
        format.html {redirect_to account_trans_path(Account), notice: 'Tran was successfully updated.'}
        format.json {render :show, status: :ok, location: @tran}
        change_status(tran_params)
      else
        format.html {render :edit}
        format.json {render json: @tran.errors, status: :unprocessable_entity}
      end
    end
  end

  # DELETE /trans/1
  # DELETE /trans/1.json
  def destroy
    @tran.destroy
    respond_to do |format|
      format.html {redirect_to user_account_path(@user, @account), notice: 'Account was successfully destroyed.'}
      format.json {head :no_content}
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_tran
    @tran = Tran.find(params[:id])
  end

  def set_account
    if current_user.admin? or current_user.tier2?
      redirect_to users_url
    elsif current_user.customer? or current_user.organization?
      @account = Account.find(params[:account_id])
      @user = current_user
    elsif current_user.tier1?
      @account = Account.find(params[:account_id]) if params[:account_id].scan(/\D/).empty?
      @user = current_user
    end
  end

  def do_transaction_specific_calculations
    if tran_params[:credit] == 'credit'
      @tran_mod = check_credit_conditions()
    elsif tran_params[:credit] == 'debit'
      @tran_mod = check_debit_conditions()
    elsif tran_params[:credit] == 'transfer'
      @tran_mod = transfer_money
    elsif tran_params[:credit] == 'request'
      @tran_mod = request_money
    end
    @tran_mod
  end

  def check_credit_conditions
    # This query is used to find the account balance
    #last_transaction = Tran.where.not(balance: nil).last
    #@tran[:balance] = last_transaction[:balance] + @tran[:amount]
    @tran[:isCritical] = @tran[:amount]>100000 ? true : false
    @tran[:isEligibleForTier1] = @tran[:amount]>100000 ? false : true

    @tran
  end

  def check_debit_conditions
    # This query is used to find the account balance
    last_transaction = Tran.where.not(balance: nil).last
    @tran[:balance] = last_transaction[:balance] - @tran[:amount]
    @tran
  end

  def transfer_money
    if @tran[:amount] >= 100000
      current_acc = Account.find_by(id: @tran[:account_id])
      current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      @tran[:status] = "pending"
      @tran[:balance] = current_tran_last_balance[:balance] - @tran[:amount]
    else
      rec_acc = find_account
      rec_acc_last_transaction = rec_acc.trans.where.not(balance: nil).last
      # Entering the record in other persons account
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'credit',
                  :balance => rec_acc_last_transaction[:balance] + @tran[:amount],
                  :user_id => rec_acc[:user_id],
                  :account_id => rec_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
      # Deducting the amount from present user balance
      current_acc = Account.find_by(id: @tran[:account_id])
      current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      @tran[:balance] = current_tran_last_balance[:balance] - @tran[:amount]
    end
    @tran

    # TODO: if account number is not found
    # TODO: Same functionality for email and phone number search
  end

  def request_money
    @tran[:status] = "pending"
    @tran
  end

  def change_status(updated_info)
    if @tran[:credit] == 'request'
      do_request_transaction_calculations
    else
      do_transfer_transaction_calculations
    end
  end

  def do_request_transaction_calculations
    if tran_params[:status] == 'approve'
      rec_acc = find_account
      # rec_acc = Account.find_by(accnumber: account_to_transfer)
      rec_acc_last_transaction = rec_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'request',
                  :balance => rec_acc_last_transaction[:balance] - @tran[:amount],
                  :user_id => rec_acc[:user_id],
                  :account_id => rec_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
      current_acc = Account.find_by(id: @tran[:account_id])
      current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'request',
                  :balance => current_tran_last_balance[:balance] + @tran[:amount],
                  :user_id => current_acc[:user_id],
                  :account_id => current_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
    elsif tran_params[:status] == 'decline'
      current_acc = Account.find_by(id: @tran[:account_id])
      current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      @tran.update_attributes(:balance => current_tran_last_balance[:balance])
      @tran.update_attributes(:credit => 'request')
    end
  end


  def do_transfer_transaction_calculations
    if tran_params[:status] == 'approve'
      account_to_transfer = find_account
      rec_acc = Account.find_by_accnumber(account_to_transfer)
      rec_acc_last_transaction = rec_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'credit',
                  :balance => rec_acc_last_transaction[:balance] + @tran[:amount],
                  :user_id => rec_acc[:user_id],
                  :account_id => rec_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
    elsif tran_params[:status] == 'decline'
      current_acc = Account.find_by(id: @tran[:account_id])
      current_acc_last_transaction = current_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'credit',
                  :balance => current_acc_last_transaction[:balance] + @tran[:amount],
                  :user_id => current_acc[:user_id],
                  :account_id => current_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
    end
  end

  def find_account
    if @tran[:transfer_account].include? '@'
      account_user = User.find_by_email(@tran[:transfer_account])
      account_to_transfer = account_user.accounts.find_by(acctype: 'checking')
    elsif @tran[:transfer_account].length == 10
      account_user = User.find_by_phone(@tran[:transfer_account])
      account_to_transfer = account_user.accounts.find_by(acctype: 'checking')
    elsif @tran[:transfer_account].length == 12
      account_to_transfer =  Account.find_by_accnumber(@tran[:transfer_account])
    end
    account_to_transfer
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tran_params
    params.require(:tran).permit(:amount, :credit, :balance, :user_id, :account_id, :transfer_account, :status)
  end
end
