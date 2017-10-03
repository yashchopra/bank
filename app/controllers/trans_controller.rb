class TransController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tran, only: [:show, :edit, :update, :destroy]
  before_action :set_account

  # GET /trans
  # GET /trans.json
  def index
    if current_user.tier1?
      @trans = Tran.where(status: 'pending')
      @user = User.where(role: 'customer').or(User.where(role: 'customer'))
    else
      user_not_authorized and return
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

  # GET /trans/1/edit
  # def edit
  # end

  # POST /trans
  # POST /trans.json
  def create
    @tran = @account.trans.create(tran_params)

    if tran_params[:credit] == 'credit'
      @tran_mod = check_credit_conditions()
    elsif tran_params[:credit] == 'debit'
      @tran_mod = check_debit_conditions()
    elsif tran_params[:credit] == 'transfer'
      @tran_mod = transfer_money()
    end

    respond_to do |format|
      if @tran_mod.save
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
  # def update
  #   respond_to do |format|
  #     if @tran.update(tran_params)
  #       format.html { redirect_to account_tran_path(@account, @tran), notice: 'Tran was successfully updated.' }
  #       format.json { render :show, status: :ok, location: @tran }
  #     else
  #       format.html { render :edit }
  #       format.json { render json: @tran.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

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
      @account = Account.find(params[:account_id]) if  params[:account_id].scan(/\D/).empty?
      @user = current_user
    end
  end

  def transfer_money
    # This query is used to find the account balance
    last_transaction = Tran.where(account_id: @account.id).last(2).first.as_json

    if @tran[:amount] >= 100000
      @tran[:status] = "Pending"
    else
      # Getting the data that was entered in form
      reciving_account_number = @tran[:transfer_account].to_s
      rec_acc = Account.where(accnumber: reciving_account_number)
      # Entering the record in other persons account
      Tran.create(:amount => @tran[:amount].to_s,
                  :credit => 'credit',
                  :balance => 'to be calculated',
                  :user_id => rec_acc.as_json[0]['user_id'],
                  :account_id => rec_acc.as_json[0]['id'],
                  :created_at => DateTime,
                  :updated_at => DateTime,
                  :transfer_account => @tran[:account_id])
      # Deducting the amount from present user balance
      @tran[:balance] = last_transaction['balance'] - @tran[:amount]
    end

    @tran

    # TODO: if account number is not found
    # TODO: Same functionality for email and phone number search
  end

  def check_credit_conditions
    # This query is used to find the account balance
    last_transaction = Tran.where(account_id: @account.id).last(2).first.as_json
    if @tran[:amount] >= 100000
      @tran[:status] = "Pending"
    else
      @tran[:balance] = last_transaction['balance'] + @tran[:amount]
    end
    @tran
  end

  def check_debit_conditions
    # This query is used to find the account balance
    last_transaction = Tran.where(account_id: @account.id).last(2).first.as_json

    if @tran[:amount] >= 100000
      @tran[:status] = "Pending"
    else
      @tran[:balance] = last_transaction['balance'] - @tran[:amount]
    end


    @tran
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tran_params
    params.require(:tran).permit(:amount, :credit, :balance, :user_id, :account_id, :transfer_account)
  end
end
