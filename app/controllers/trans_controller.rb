class TransController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tran, only: [:show, :edit, :update, :destroy]
  before_action :set_account

  # GET /trans
  # GET /trans.json
  def index
    # @trans = Tran.all
    @trans = @account.trans.all
  end

  # GET /trans/1
  # GET /trans/1.json
  def show
  end

  # GET /trans/new
  def new
    # @tran = Tran.new
    @tran = @account.trans.new
  end

  # GET /trans/1/edit
  def edit
  end

  # POST /trans
  # POST /trans.json
  def create
    @tran = @account.trans.create(tran_params)
    # @tran = Tran.new(tran_params)

    respond_to do |format|
      if @tran.save
        format.html { redirect_to account_tran_path(@account, @tran), notice: 'Tran was successfully created.' }
        format.json { render :show, status: :created, location: @tran }
      else
        format.html { render :new }
        format.json { render json: @tran.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trans/1
  # PATCH/PUT /trans/1.json
  def update
    respond_to do |format|
      if @tran.update(tran_params)
        format.html { redirect_to account_tran_path(@account, @tran), notice: 'Tran was successfully updated.' }
        format.json { render :show, status: :ok, location: @tran }
      else
        format.html { render :edit }
        format.json { render json: @tran.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trans/1
  # DELETE /trans/1.json
  def destroy
    @tran.destroy
    respond_to do |format|
      format.html { redirect_to account_trans_path(@account), notice: 'Tran was successfully destroyed.' }
      format.json { head :no_content }
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
      elsif current_user.tier1?
        @user = current_user
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tran_params
      params.require(:tran).permit(:amount, :credit, :balance, :user_id, :account_id)
    end
end
