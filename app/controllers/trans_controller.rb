class TransController < ApplicationController
  before_action :authenticate_user!
  before_action :my_logger
  before_action :set_tran, only: [:show, :edit, :update, :destroy]
  before_action :set_account
  before_action :trans_type_checker, only:[:new, :create]

  # GET /trans
  # GET /trans.json
  def index
    if current_user.tier1?
      @trans = Tran.where(status: 'pending', isEligibleForTier1: 'yes')
      @user = User.where(role: 'customer').or(User.where(role: 'organization'))
      @user_list = User.where(role: 'customer').or(User.where(role: 'organization'))
    elsif current_user.tier2?
      @trans = Tran.where(status: 'pending')
      @user = User.where(role: 'customer', :status => 'pending').or(User.where(role: 'organization', :status => 'pending'))
      @user_list = User.where(role: 'customer').or(User.where(role: 'organization'))
    else
      user_not_authorized and return
    end
    $my_logger.info("Rendering transactions")
  end

  # GET /trans/1
  # GET /trans/1.json
  # def show
  # end

  # GET /trans/new
  def new
    # @tran = Tran.new
    @tran = @account.trans.new
    trans_type_checker
    $my_logger.info("Opening new transactions page")
  end

  def trans_type_checker
    @tran = @account.trans.new
    if !@tran.nil?
      at_checker = Account.find_by_id(@tran[:account_id])[:acctype]
    end
    if at_checker == "Credit Card"
      @trans_types = ['pay', 'spend']
    elsif (at_checker == "Checking" or at_checker == "Savings") and (current_user.tier1? or current_user.tier2?)
      @trans_types = ['credit', 'debit', 'transfer', 'request']
    elsif (at_checker == "Checking" or at_checker == "Savings") and current_user.customer?
      @trans_types = ['transfer']
    elsif (at_checker == "Checking") and current_user.organization?
      @trans_types = ['transfer', 'request']
    else
      @trans_types = ['Dummy']
    end
  end


  # GET /trans/1/edit
  # def edit
  # end

  # POST /trans
  # POST /trans.json
  def create
    trans_type_checker
    if ((current_user.customer? or current_user.organization?) && @account.authenticate_otp(tran_params[:transaction_otp],drift: 120) && tran_params[:credit] != 'fee') or ((current_user.tier1? or current_user.tier2?) && tran_params[:credit] != 'fee')
      #if tran_params[:credit] != 'fee'
      @tran = @account.trans.create(tran_params)
      respond_to do |format|
        @tran = do_transaction_specific_calculations
        if @tran.save
          format.html {redirect_to user_account_path(@user, @account), notice: 'Tran was successfully created.'}
          format.json {render :show, status: :created, location: @tran}
        else
          format.html {render :new}
          format.json {render json: @tran_mod.errors, status: :unprocessable_entity}
        end
      end
    else

      respond_to do |format|
        format.html {render :new, notice: 'Transaction Unsuccessful!'}
        format.json {render json: 'Transaction Unsuccessful', status: :unprocessable_entity}
      end
      $my_logger.info("Creating new transactions")
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
        format.html {redirect_to account_trans_path(Account), notice: 'Tran update cancelled.'}
        format.json {render json: @tran.errors, status: :unprocessable_entity}
      end
    end
    $my_logger.info("Update transactions")
  end

  # DELETE /trans/1
  # DELETE /trans/1.json
  # def destroy
  #   if not current_user.customer?
  #     @tran.destroy
  #     respond_to do |format|
  #       format.html {redirect_to user_account_path(@user, @account), notice: 'Account was successfully destroyed.'}
  #       format.json {head :no_content}
  #     end
  #   end
  # end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_tran
    @tran = Tran.find(params[:id])
  end

  def set_account
    if current_user.admin?
      redirect_to users_url
    elsif current_user.customer? or current_user.organization?
      @account = Account.find(params[:account_id])
      @user = current_user
    elsif current_user.tier1? or current_user.tier2?
      @account = Account.find(params[:account_id]) if params[:account_id].scan(/\D/).empty?
      @user = current_user
    end
  end

  def do_transaction_specific_calculations
    if tran_params[:credit] == 'credit' or tran_params[:credit] == 'spend'
      @tran_mod = check_credit_conditions
    elsif tran_params[:credit] == 'debit' or tran_params[:credit] == 'pay'
      @tran_mod = check_debit_conditions
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
    #@tran[:balance] = last_transaction[:balance] +  @tran[:amount]
    at_checker = Account.find_by_id(@tran[:account_id])[:acctype]
    if at_checker == "Credit Card"
      last_transaction = Tran.where.not(balance: nil).last
      @tran[:balance] = last_transaction[:balance] + @tran[:amount]
    else
      #@tran[:balance] = last_transaction[:balance] + @tran[:amount]
      if current_user.tier1?
        @tran[:externaluserapproval] == 'reject'
      else
        @tran[:externaluserapproval] == 'accept'
      end
      if @tran[:amount] > 100000.00
        @tran[:isEligibleForTier1] = 'no'
        @tran[:status] = "pending"
        @tran[:isCritical] = 'true'
      else
        @tran[:isCritical] = "false"
        @tran[:isEligibleForTier1] = "yes"
        @tran[:status] = "pending"
      end
    end
    @tran

  end

  def check_debit_conditions

    # This query is used to find the account balance
    # last_transaction = Tran.where.not(balance: nil).last
    # @tran[:balance] = last_transaction[:balance] - @tran[:amount]
    at_checker = Account.find_by_id(@tran[:account_id])[:acctype]
    if at_checker == "Credit Card"
      last_transaction = Tran.where.not(balance: nil).last
      @tran[:balance] = last_transaction[:balance] - @tran[:amount]
      # @account.update_attributes(:statement_balance => @account[:statement_balance].to_int - @tran[:amount]) if  @account[:statement_balance]
    else
      if current_user.tier1?
        @tran[:externaluserapproval] == 'reject'
      else
        @tran[:externaluserapproval] == 'accept'
      end
      if @tran[:amount]>100000
        @tran[:isCritical] = 'true'
        @tran[:isEligibleForTier1] = 'no'
        @tran[:status] = "pending"
      else
        @tran[:isCritical] = 'false'
        @tran[:isEligibleForTier1] = 'yes'
        @tran[:status] = "pending"
      end
    end
    @tran
  end

  def transfer_money
    if current_user.tier1?
      @tran[:externaluserapproval] == 'reject'
    else
      @tran[:externaluserapproval] == 'accept'
    end
    if @tran[:amount]>100000
      current_acc = Account.find_by(id: @tran[:account_id])
      current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      @tran[:status] = "pending"
      # @tran[:balance] = current_tran_last_balance[:balance] - @tran[:amount]
      @tran[:isCritical] = 'true'
      @tran[:isEligibleForTier1] = 'no'
    else
      @tran[:isCritical] = 'false'
      @tran[:isEligibleForTier1] = 'yes'
      @tran[:status] = "pending"

      # rec_acc = find_account
      # rec_acc_last_transaction = rec_acc.trans.where.not(balance: nil).last
      # # Entering the record in other persons account
      # Tran.create(:amount => @tran[:amount].to_s,
      #             :credit => 'credit',
      #             :balance => rec_acc_last_transaction[:balance] + @tran[:amount],
      #             :user_id => rec_acc[:user_id],
      #             :account_id => rec_acc[:id],
      #             :created_at => DateTime,
      #             :updated_at => DateTime,
      #             :transfer_account => @tran[:account_id])
      # # Deducting the amount from present user balance
      # current_acc = Account.find_by(id: @tran[:account_id])
      # current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      # @tran[:balance] = current_tran_last_balance[:balance] - @tran[:amount]

    end
    @tran
  end

  def request_money
    if current_user.tier1?
      @tran[:externaluserapproval] == 'reject'
    else
      @tran[:externaluserapproval] == 'accept'
    end
    if @tran[:amount]>100000
      @tran[:isCritical] = 'true'
      @tran[:isEligibleForTier1] = 'no'
      @tran[:status] = "pending"
    else
      @tran[:isCritical] = 'false'
      @tran[:isEligibleForTier1] = 'yes'
      @tran[:status] = "pending"
    end

    @tran
  end

  def change_status(updated_info)
    if @tran[:credit] == 'credit'
      do_credit_transaction_calculations
    elsif @tran[:credit] == 'debit'
      do_debit_transaction_calculations
    elsif @tran[:credit] == 'request'
      do_request_transaction_calculations
    elsif @tran[:credit] == 'transfer'
      do_transfer_transaction_calculations
    end
  end

  def do_credit_transaction_calculations
    if tran_params[:status] == 'approve'
      current_acc = Account.find_by(id: @tran[:account_id])
      current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'credit',
                  :balance => current_tran_last_balance[:balance] + @tran[:amount],
                  :user_id => current_acc[:user_id],
                  :account_id => current_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
      Tran.find_by(id: @tran[:id]).delete
    elsif tran_params[:status] == 'decline'
      Tran.find_by(id: @tran[:id]).delete
      # @tran.update_attributes(:explanation => 'Your transaction was declined')
    end
  end

  def do_debit_transaction_calculations
    if tran_params[:status] == 'approve'
      current_acc = Account.find_by(id: @tran[:account_id])
      current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'debit',
                  :balance => current_tran_last_balance[:balance] - @tran[:amount],
                  :user_id => current_acc[:user_id],
                  :account_id => current_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
      Tran.find_by(id: @tran[:id]).delete
    elsif tran_params[:status] == 'decline'
      Tran.find_by(id: @tran[:id]).delete
      # @tran.update_attributes(:explanation => 'Your transaction was declined')
    end
  end

  def do_request_transaction_calculations
    if tran_params[:status] == 'approve'
      rec_acc = find_account
      rec_acc_last_transaction = rec_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'debit',
                  :balance => rec_acc_last_transaction[:balance] - @tran[:amount],
                  :user_id => rec_acc[:user_id],
                  :account_id => rec_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
      Tran.find_by(id: @tran[:id]).delete
      current_acc = Account.find_by(id: @tran[:account_id])
      current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'credit',
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
      rec_acc = find_account
      rec_acc_last_transaction = rec_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'credit',
                  :balance => rec_acc_last_transaction[:balance] + @tran[:amount],
                  :user_id => rec_acc[:user_id],
                  :account_id => rec_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
      Tran.find_by(id: @tran[:id]).delete
      current_acc = Account.find_by(id: @tran[:account_id])
      current_tran_last_balance = current_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'debit',
                  :balance => current_tran_last_balance[:balance] - @tran[:amount],
                  :user_id => current_acc[:user_id],
                  :account_id => current_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
    elsif tran_params[:status] == 'decline'
      current_acc = Account.find_by(id: @tran[:account_id])
      current_acc_last_transaction = current_acc.trans.where.not(balance: nil).last
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'transfer',
                  :balance => current_acc_last_transaction[:balance],
                  :user_id => current_acc[:user_id],
                  :account_id => current_acc[:id],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
      Tran.find_by(id: @tran[:id]).delete
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
      account_to_transfer = Account.find_by_accnumber(@tran[:transfer_account])
    elsif @tran[:transfer_account].length == 16
      account_to_transfer = Account.find_by_accnumber(@tran[:transfer_account])
    end
    account_to_transfer
  end

  def my_logger
    $my_logger ||= Logger.new("#{Rails.root}/log/my.log")
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tran_params
    params.require(:tran).permit(:amount, :credit, :balance, :user_id, :account_id, :transfer_account, :status, :isEligibleForTier1, :isCritical, :transaction_otp, :routingNum)
  end
end


